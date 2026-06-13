// lib/services/firebase_service.dart
//
// Service tổng hợp kết nối Firebase cho iCa.
// Toàn bộ dữ liệu (khách hàng, hải sản, báo giá, công nợ, nhập xuất, thông báo)
// được lưu & lấy trên Firestore. Ảnh lưu trên Firebase Storage.
// Đăng nhập/đăng ký qua Firebase Auth. Push notification qua FCM.
//
// Cấu trúc Firestore:
//   users/{uid}/
//     profile           (doc: name, email, phone, avatarUrl)
//     customers/{id}
//     seafood/{id}
//     quotes/{id}
//     debts/{id}
//     inventory/{id}
//     notifications/{id}
//   devices/{token}     (uid, platform, updatedAt) — để gửi FCM
//
// Cách dùng: gọi FirebaseService.instance.<method>()

import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models.dart';
import '../constants.dart';

class FirebaseService {
  FirebaseService._();
  static final FirebaseService instance = FirebaseService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;

  // ── Auth helpers ──────────────────────────────────────────────────────────────
  User? get currentUser => _auth.currentUser;
  String? get uid => _auth.currentUser?.uid;
  bool get isLoggedIn => _auth.currentUser != null;

  /// Stream trạng thái đăng nhập — dùng cho AuthGate
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // ── Đường dẫn collection theo user ──────────────────────────────────────────────
  CollectionReference<Map<String, dynamic>> _col(String name) {
    final u = uid;
    if (u == null) throw StateError('Chưa đăng nhập');
    return _db.collection('users').doc(u).collection(name);
  }

  DocumentReference<Map<String, dynamic>> get _profileDoc =>
      _db.collection('users').doc(uid);

  // ════════════════════════════════════════════════════════════════════════════
  //  AUTHENTICATION
  // ════════════════════════════════════════════════════════════════════════════

  /// Đăng nhập bằng email + mật khẩu
  Future<AppUser> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    await _registerDeviceToken(); // đăng ký token đẩy thông báo
    final snap = await _profileDoc.get();
    final data = snap.data();
    return AppUser(
      name: data?['name'] ?? cred.user!.email!.split('@').first,
      email: cred.user!.email!,
    );
  }

  /// Đăng ký tài khoản mới
  Future<AppUser> signUp({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);

    await cred.user!.updateDisplayName(name);

    // tạo profile + seed dữ liệu mặc định
    await _profileDoc.set({
      'name': name,
      'email': email.trim(),
      'phone': phone,
      'avatarUrl': null,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Seed khách hàng + hải sản mẫu (giữ nguyên id '1'..'6' / '1'..'5')
    final batch = _db.batch();
    for (final c in kInitCustomers) {
      batch.set(_col('customers').doc(c.id), c.toMap());
    }
    for (final s in kInitSeafood) {
      batch.set(_col('seafood').doc(s.id), s.toMap());
    }
    await batch.commit();

    await _registerDeviceToken();
    return AppUser(name: name, email: email.trim());
  }

  /// Đăng xuất — xoá token nền, không block _auth.signOut()
  Future<void> signOut() async {
    _removeDeviceToken().timeout(const Duration(seconds: 5)).catchError((_) {});
    await _auth.signOut();
  }

  /// Fallback: ép đăng xuất ngay không cần cleanup
  Future<void> forceSignOut() => _auth.signOut();

  /// Gửi email đặt lại mật khẩu
  Future<void> sendPasswordReset(String email) =>
      _auth.sendPasswordResetEmail(email: email.trim());

  /// Đổi mật khẩu (khi đã đăng nhập)
  Future<void> updatePassword(String newPassword) async {
    await _auth.currentUser?.updatePassword(newPassword);
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  SEED — tạo dữ liệu mẫu lần đầu (giữ nguyên id để liên kết tồn kho/khách)
  // ════════════════════════════════════════════════════════════════════════════
  Future<void> seedDefaultsIfEmpty({
    required List<Customer> customers,
    required List<Seafood> seafood,
    required List<InventoryEntry> inventory,
  }) async {
    if (uid == null) return;
    final existing = await _col('seafood').limit(1).get();
    if (existing.docs.isNotEmpty) return; // đã có dữ liệu -> bỏ qua
    final batch = _db.batch();
    for (final c in customers) { batch.set(_col('customers').doc(c.id), c.toMap()); }
    for (final s in seafood)   { batch.set(_col('seafood').doc(s.id), s.toMap()); }
    for (final e in inventory) { batch.set(_col('inventory').doc(e.id), e.toMap()); }
    await batch.commit();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  CUSTOMERS  (khách hàng)
  // ════════════════════════════════════════════════════════════════════════════

  Stream<List<Customer>> watchCustomers() => _col('customers')
      .orderBy('name')
      .snapshots()
      .map((q) => q.docs.map((d) => Customer.fromMap(d.id, d.data())).toList());

  Future<List<Customer>> getCustomers() async {
    final q = await _col('customers').orderBy('name').get();
    return q.docs.map((d) => Customer.fromMap(d.id, d.data())).toList();
  }

  Future<String> addCustomer(Customer c, {Uint8List? avatarBytes}) async {
    final ref = await _col('customers').add(c.toMap());
    if (avatarBytes != null) {
      final url = await _uploadImage('avatars/${ref.id}.jpg', avatarBytes);
      await ref.update({'avatarUrl': url});
    }
    return ref.id;
  }

  Future<void> updateCustomer(Customer c, {Uint8List? newAvatarBytes}) async {
    final data = c.toMap();
    if (newAvatarBytes != null) {
      data['avatarUrl'] =
          await _uploadImage('avatars/${c.id}.jpg', newAvatarBytes);
    }
    await _col('customers').doc(c.id.toString()).update(data);
  }

  /// Chỉ cập nhật avatar — không đụng đến các field khác.
  Future<void> updateCustomerAvatar(String customerId, Uint8List bytes) async {
    final ref  = _storage.ref('users/$uid/avatars/$customerId.jpg');
    final snap = await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    final url  = await snap.ref.getDownloadURL();
    await _col('customers').doc(customerId).update({'avatarUrl': url});
  }

  Future<void> updateCoefficient(String customerId, double coeff) =>
      _col('customers').doc(customerId).update({'coefficient': coeff});

  Future<void> deleteCustomer(String customerId) async {
    await _col('customers').doc(customerId).delete();
    await _deleteImageSafe('avatars/$customerId.jpg');
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  SEAFOOD  (giá gốc hải sản)
  // ════════════════════════════════════════════════════════════════════════════

  Stream<List<Seafood>> watchSeafood() => _col('seafood')
      .snapshots()
      .map((q) => q.docs.map((d) => Seafood.fromMap(d.id, d.data())).toList());

  Future<List<Seafood>> getSeafood() async {
    final q = await _col('seafood').get();
    return q.docs.map((d) => Seafood.fromMap(d.id, d.data())).toList();
  }

  Future<String> addSeafood(Seafood s) async {
    final ref = await _col('seafood').add(s.toMap());
    return ref.id;
  }

  Future<void> updateBasePrice(String seafoodId, double price) =>
      _col('seafood').doc(seafoodId).update({'basePrice': price});

  Future<void> updateSeafood(Seafood s) =>
      _col('seafood').doc(s.id).update(s.toMap());

  Future<void> deleteSeafood(String seafoodId) =>
      _col('seafood').doc(seafoodId).delete();

  // ════════════════════════════════════════════════════════════════════════════
  //  QUOTES  (báo giá)
  // ════════════════════════════════════════════════════════════════════════════

  Stream<List<Quote>> watchQuotes() => _col('quotes')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((q) => q.docs.map((d) => Quote.fromMap(d.id, d.data())).toList());

  Future<String> addQuote(Quote quote) async {
    final data = quote.toMap()..['createdAt'] = FieldValue.serverTimestamp();
    final ref = await _col('quotes').add(data);
    return ref.id;
  }

  Future<void> deleteQuote(String quoteId) =>
      _col('quotes').doc(quoteId).delete();

  // ════════════════════════════════════════════════════════════════════════════
  //  DEBTS  (công nợ)  — kèm ảnh trên Storage
  // ════════════════════════════════════════════════════════════════════════════

  Stream<List<DebtRecord>> watchDebts() => _col('debts')
      .orderBy('createdDate', descending: true)
      .snapshots()
      .map((q) => q.docs.map((d) => DebtRecord.fromMap(d.id, d.data())).toList());

  Future<List<DebtRecord>> getDebts() async {
    final q = await _col('debts').orderBy('createdDate', descending: true).get();
    return q.docs.map((d) => DebtRecord.fromMap(d.id, d.data())).toList();
  }

  /// Thêm công nợ. Nếu có ảnh -> upload Storage trước, rồi tạo doc Firestore 1 lần với imageUrl đã có.
  Future<String> addDebt(DebtRecord debt, {Uint8List? imageBytes, String customerName = ''}) async {
    final data = debt.toMap();
    if (imageBytes != null) {
      // Upload trước khi tạo doc — dùng debt.id làm path ổn định
      data['imageUrl'] = await _uploadImage('debts/${debt.id}.jpg', imageBytes);
    }
    await _col('debts').doc(debt.id).set(data);
    await _notifyAllDevices(
      title: customerName.isNotEmpty ? 'Công nợ mới · $customerName' : 'Công nợ mới',
      body: '${debt.amount.toStringAsFixed(0)}đ',
      tab: 'debt',
    );
    return debt.id;
  }

  /// Cập nhật nội dung công nợ (số tiền, ngày, ghi chú) + ảnh tuỳ chọn.
  /// imageAction: null = giữ nguyên, 'remove' = xoá, Uint8List = thay mới.
  Future<void> updateDebt(DebtRecord debt, {dynamic imageAction}) async {
    final data = debt.toMap();
    if (imageAction is Uint8List) {
      data['imageUrl'] =
          await _uploadImage('debts/${debt.id}.jpg', imageAction);
    } else if (imageAction == 'remove') {
      data['imageUrl'] = null;
      await _deleteImageSafe('debts/${debt.id}.jpg');
    }
    await _col('debts').doc(debt.id).update(data);
    await _notifyAllDevices(
      title: 'Cập nhật công nợ',
      body: '${debt.amount.toStringAsFixed(0)}đ',
    );
  }

  /// Thêm/đổi ảnh cho công nợ có sẵn
  Future<String> addImageToDebt(String debtId, Uint8List imageBytes) async {
    final url = await _uploadImage('debts/$debtId.jpg', imageBytes);
    await _col('debts').doc(debtId).update({'imageUrl': url});
    await _notifyAllDevices(title: 'Cập nhật ảnh công nợ', body: '');
    return url;
  }

  Future<void> markDebtPaid(String debtId, double amount, {String customerName = ''}) async {
    await _col('debts').doc(debtId).update({
      'isPaid': true,
      'paidDate': _todayStr(),
    });
    await _notifyAllDevices(
      title: customerName.isNotEmpty ? 'Đã thu tiền · $customerName' : 'Đã thu tiền',
      body: '${amount.toStringAsFixed(0)}đ',
      tab: 'debt',
    );
  }

  Future<void> deleteDebt(String debtId) async {
    await _col('debts').doc(debtId).delete();
    await _deleteImageSafe('debts/$debtId.jpg');
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  INVENTORY  (nhập xuất)
  // ════════════════════════════════════════════════════════════════════════════

  Stream<List<InventoryEntry>> watchInventory() => _col('inventory')
      .orderBy('date', descending: true)
      .snapshots()
      .map((q) =>
          q.docs.map((d) => InventoryEntry.fromMap(d.id, d.data())).toList());

  Future<String> addInventoryEntry(InventoryEntry e) async {
    final ref = await _col('inventory').add(e.toMap());
    return ref.id;
  }

  Future<void> deleteInventoryEntry(String entryId) =>
      _col('inventory').doc(entryId).delete();

  // ════════════════════════════════════════════════════════════════════════════
  //  NOTIFICATIONS  (thông báo lưu trên Firestore)
  // ════════════════════════════════════════════════════════════════════════════

  Stream<List<AppNotification>> watchNotifications() => _col('notifications')
      .orderBy('ts', descending: true)
      .snapshots()
      .map((q) =>
          q.docs.map((d) => AppNotification.fromMap(d.id, d.data())).toList());

  Future<void> addNotification(AppNotification n) =>
      _col('notifications').add(n.toMap());

  Future<void> markNotificationRead(String id) =>
      _col('notifications').doc(id).update({'read': true});

  Future<void> markAllNotificationsRead() async {
    final q = await _col('notifications').where('read', isEqualTo: false).get();
    final batch = _db.batch();
    for (final d in q.docs) {
      batch.update(d.reference, {'read': true});
    }
    await batch.commit();
  }

  Future<void> deleteNotification(String id) =>
      _col('notifications').doc(id).delete();

  Future<void> clearNotifications() async {
    final q = await _col('notifications').get();
    final batch = _db.batch();
    for (final d in q.docs) {
      batch.delete(d.reference);
    }
    await batch.commit();
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  STORAGE helpers
  // ════════════════════════════════════════════════════════════════════════════

  Future<String> _uploadImage(String path, Uint8List bytes) async {
    final ref = _storage.ref('users/$uid/$path');
    await ref.putData(bytes, SettableMetadata(contentType: 'image/jpeg'))
        .timeout(const Duration(seconds: 30));
    return ref.getDownloadURL()
        .timeout(const Duration(seconds: 10));
  }

  Future<void> _deleteImageSafe(String path) async {
    try {
      await _storage.ref('users/$uid/$path').delete();
    } catch (_) {
      // ảnh không tồn tại — bỏ qua
    }
  }

  /// Tải ảnh về dạng bytes (nếu cần hiển thị offline)
  Future<Uint8List?> downloadImage(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      return await ref.getData(10 * 1024 * 1024); // tối đa 10MB
    } catch (_) {
      return null;
    }
  }

  // ════════════════════════════════════════════════════════════════════════════
  //  FCM — Cloud Messaging
  // ════════════════════════════════════════════════════════════════════════════

  /// Xin quyền + đăng ký token thiết bị (gọi sau khi đăng nhập)
  Future<void> initMessaging() async {
    try {
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
      await _registerDeviceToken();
      _fcm.onTokenRefresh.listen((_) => _registerDeviceToken());
    } catch (_) {}
  }

  /// Lưu token thiết bị vào collection devices để server gửi push
  Future<void> _registerDeviceToken() async {
    final u = uid;
    if (u == null) return;
    final token = await _fcm.getToken()
        .timeout(const Duration(seconds: 10), onTimeout: () => null);
    if (token == null) return;
    await _db.collection('devices').doc(token).set({
      'uid': u,
      'token': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> _removeDeviceToken() async {
    final token = await _fcm.getToken()
        .timeout(const Duration(seconds: 8), onTimeout: () => null);
    if (token != null) {
      await _db.collection('devices').doc(token).delete().catchError((_) {});
    }
  }

  /// Ghi 1 "yêu cầu gửi push" vào Firestore.
  /// Một Cloud Function (xem firebase_setup.md) sẽ lắng nghe collection
  /// `push_queue` và gửi FCM tới tất cả thiết bị của user.
  Future<void> _notifyAllDevices({
    required String title,
    required String body,
    String tab = 'debt',
  }) async {
    final u = uid;
    if (u == null) return;
    await _db.collection('push_queue').add({
      'uid': u,
      'title': title,
      'body': body,
      'tab': tab,
      'createdAt': FieldValue.serverTimestamp(),
      'sent': false,
    });
  }

  // ── util ──
  String _todayStr() {
    final n = DateTime.now();
    return '${n.year}-${n.month.toString().padLeft(2, '0')}-${n.day.toString().padLeft(2, '0')}';
  }
}
