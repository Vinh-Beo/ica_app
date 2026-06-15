// lib/app_state.dart
//
// AppState nối THẲNG với Firebase (Firestore realtime).
//  • Dữ liệu (customers, seafood, quotes, debts, inventory, notifications)
//    được lắng nghe realtime từ Firestore qua FirebaseService.
//  • Mọi thao tác thêm/sửa/xoá gọi FirebaseService → Firestore tự đẩy về stream.
//  • State chỉ-UI (khách đang chọn, tháng/năm báo giá, giá bán ghi đè, chọn mặt hàng)
//    giữ cục bộ trong bộ nhớ.
//  • Tự bind/unbind theo trạng thái đăng nhập Firebase.

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'models.dart';
import 'constants.dart';
import 'services/firebase_service.dart';

class AppState extends ChangeNotifier {
  final _fb = FirebaseService.instance;

  AppState() {
    // tự gắn/huỷ stream theo đăng nhập
    _authSub = _fb.authStateChanges().listen((user) {
      if (user != null) {
        _bind();
      } else {
        _unbind();
      }
    });
    if (_fb.isLoggedIn) _bind();
  }

  // ── Auth ────────────────────────────────────────────────────────────────────
  bool get isLoggedIn => _fb.isLoggedIn;

  AppUser? get currentUser {
    final u = _fb.currentUser;
    if (u == null) return null;
    return AppUser(name: u.displayName ?? u.email?.split('@').first ?? '', email: u.email ?? '');
  }

  /// Tên người dùng hiện tại (Firebase) — dùng cho nhãn "tạo bởi"
  String get currentUserName {
    final u = _fb.currentUser;
    return u?.displayName ?? u?.email?.split('@').first ?? '';
  }

  Future<void> logout() => _fb.signOut();

  // ── Dữ liệu realtime (từ Firestore) ─────────────────────────────────────────
  List<Customer>        customers       = [];
  List<Seafood>         seafood         = [];
  List<Quote>           quotes          = [];
  List<DebtRecord>      debts           = [];
  List<InventoryEntry>  inventoryEntries = [];
  List<AppNotification> notifications   = [];
  bool loading = true;

  StreamSubscription? _authSub;
  final List<StreamSubscription> _subs = [];

  void _bind() {
    _cancelData();
    loading = true;
    notifyListeners();

    _subs.add(_fb.watchCustomers().listen((d) {
      customers = d;
      // đảm bảo khách đang chọn còn tồn tại
      if (customers.isNotEmpty && !customers.any((c) => c.id == selectedCustomerId)) {
        selectedCustomerId = customers.first.id;
      }
      notifyListeners();
    }));
    _subs.add(_fb.watchSeafood().listen((d)   { seafood = d;          notifyListeners(); }));
    _subs.add(_fb.watchQuotes().listen((d)    { quotes = d;           notifyListeners(); }));
    _subs.add(_fb.watchDebts().listen((d)     { debts = d;            notifyListeners(); }));
    _subs.add(_fb.watchInventory().listen((d) { inventoryEntries = d; notifyListeners(); }));
    _subs.add(_fb.watchNotifications().listen((d) {
      notifications = d;
      loading = false;
      notifyListeners();
    }));
  }

  void _cancelData() {
    for (final s in _subs) { s.cancel(); }
    _subs.clear();
  }

  void _unbind() {
    _cancelData();
    customers = []; seafood = []; quotes = [];
    debts = []; inventoryEntries = []; notifications = [];
    notifyListeners();
  }

  @override
  void dispose() { _cancelData(); _authSub?.cancel(); super.dispose(); }

  // ── Notifications ─────────────────────────────────────────────────────────────
  int get unreadCount => notifications.where((n) => !n.read).length;
  int get onlineDevices => 2;

  /// Ghi 1 thông báo vào Firestore (hiện realtime ở tab Thông báo).
  void addNotification({required String type, required String title, required String body}) {
    _fb.addNotification(AppNotification(
      id: uid(), type: type, title: title, body: body,
      ts: DateTime.now().millisecondsSinceEpoch,
      deviceCount: onlineDevices, by: currentUserName,
    ));
  }

  void markAllRead()              => _fb.markAllNotificationsRead();
  void markRead(String id)        => _fb.markNotificationRead(id);
  void clearNotifications()       => _fb.clearNotifications();
  void deleteNotification(String id) => _fb.deleteNotification(id);

  // ── Quote UI state (cục bộ) ──────────────────────────────────────────────────
  String selectedCustomerId = '1';
  int    quoteMonth = DateTime.now().month - 1;
  int    quoteYear  = DateTime.now().year;
  Map<String, Map<String, String>> sellOverride = {}; // custId → sfId → price string
  Set<String>? selectedItems; // null = chọn tất cả

  Customer get selectedCustomer => customers.firstWhere(
      (c) => c.id == selectedCustomerId,
      orElse: () => customers.isNotEmpty ? customers.first
                                         : Customer(id: '', name: '—', type: '', coefficient: 1));

  List<Seafood> get pricedSeafood => seafood.where((s) => s.basePrice > 0).toList();
  bool isSelected(String sfId) => selectedItems == null || selectedItems!.contains(sfId);
  List<Seafood> get quoteItems => pricedSeafood.where((s) => isSelected(s.id)).toList();

  double getSellPrice(String sfId, double base) {
    final ov = sellOverride[selectedCustomerId]?[sfId];
    if (ov != null && ov.isNotEmpty) return double.tryParse(ov) ?? 0;
    return base * selectedCustomer.coefficient;
  }

  bool isOverridden(String sfId) {
    final ov = sellOverride[selectedCustomerId]?[sfId];
    return ov != null && ov.isNotEmpty;
  }

  void setSellOverride(String sfId, String raw) {
    final clean = raw.replaceAll(RegExp(r'[^0-9]'), '');
    sellOverride = Map.from(sellOverride)
      ..update(selectedCustomerId, (m) => Map.from(m)..[sfId] = clean, ifAbsent: () => {sfId: clean});
    notifyListeners();
  }

  void resetSellOverride(String sfId) {
    sellOverride[selectedCustomerId]?.remove(sfId);
    notifyListeners();
  }

  void toggleItem(String sfId) {
    final all = pricedSeafood.map((s) => s.id).toSet();
    final cur = selectedItems ?? all;
    selectedItems = cur.contains(sfId) ? (Set<String>.from(cur)..remove(sfId))
                                       : (Set<String>.from(cur)..add(sfId));
    notifyListeners();
  }

  void toggleAll() {
    final all = pricedSeafood.map((s) => s.id).toSet();
    selectedItems = all.every(isSelected) ? <String>{} : null;
    notifyListeners();
  }

  void setSelectedCustomer(String id) { selectedCustomerId = id; notifyListeners(); }
  void setQuoteMonth(int m) { quoteMonth = m; notifyListeners(); }
  void setQuoteYear(int y)  { quoteYear = y;  notifyListeners(); }

  // ── Seafood mutations → Firebase ─────────────────────────────────────────────
  Future<void> addSeafood(Seafood sf)         => _fb.addSeafood(sf);
  void deleteSeafood(String id)               { _fb.deleteSeafood(id); }
  Future<void> updateBasePrice(String id, double price) => _fb.updateBasePrice(id, price);
  Future<void> updateSeafood(Seafood sf)      => _fb.updateSeafood(sf);

  // ── Customer mutations → Firebase ────────────────────────────────────────────
  void addCustomer(Customer c)                { _fb.addCustomer(c); }
  void deleteCustomer(String id)              { _fb.deleteCustomer(id); }
  void updateCoefficient(String id, double coeff) { _fb.updateCoefficient(id, coeff); }
  Future<void> updateCustomer(Customer c, {Uint8List? newAvatarBytes}) =>
      _fb.updateCustomer(c, newAvatarBytes: newAvatarBytes);
  Future<void> updateCustomerInfo(Customer c) => _fb.updateCustomer(c);
  Future<void> updateCustomerAvatar(String customerId, Uint8List bytes) =>
      _fb.updateCustomerAvatar(customerId, bytes);

  // ── Quote mutations → Firebase ───────────────────────────────────────────────
  void saveQuote() {
    final items = quoteItems.map((s) => QuoteItem(
      id: s.id, name: s.name, unit: s.unit, icon: s.icon,
      basePrice: s.basePrice, sellPrice: getSellPrice(s.id, s.basePrice),
    )).toList();
    if (items.isEmpty) return;
    final c = selectedCustomer;
    _fb.addQuote(Quote(
      id: uid(), month: quoteMonth, year: quoteYear,
      customerName: c.name, customerType: c.type, coefficient: c.coefficient,
      items: items, createdAt: DateTime.now().toIso8601String(),
    ));
  }

  void deleteQuote(String id) { _fb.deleteQuote(id); }

  // ── Debt mutations → Firebase ────────────────────────────────────────────────
  Future<void> addDebt(DebtRecord d) async {
    final cust = customers.firstWhere((c) => c.id == d.customerId,
        orElse: () => Customer(id: '', name: '', type: '', coefficient: 1));
    await _fb.addDebt(d, imageBytes: d.imageBytes, customerName: cust.name);
    addNotification(
      type: 'debt_new',
      title: 'Công nợ mới · ${cust.name}',
      body: '${fmt(d.amount)}đ · Giao: ${fmtDate(d.deliveryDate)}${d.note.isNotEmpty ? ' · ${d.note}' : ''}',
    );
  }

  void markDebtPaid(String id) {
    final d = debts.firstWhere((x) => x.id == id,
        orElse: () => DebtRecord(id: id, customerId: '', amount: 0, deliveryDate: '', createdDate: ''));
    final cust = customers.firstWhere((c) => c.id == d.customerId,
        orElse: () => Customer(id: '', name: '', type: '', coefficient: 1));
    _fb.markDebtPaid(id, d.amount, customerName: cust.name);
    addNotification(
      type: 'debt_paid',
      title: 'Đã thu nợ · ${cust.name}',
      body: '${fmt(d.amount)}đ · Đã trả ${fmtDate(todayStr())}',
    );
  }

  void deleteDebt(String id) {
    final d = debts.firstWhere((x) => x.id == id,
        orElse: () => DebtRecord(id: id, customerId: '', amount: 0, deliveryDate: '', createdDate: ''));
    final cust = customers.firstWhere((c) => c.id == d.customerId,
        orElse: () => Customer(id: '', name: '', type: '', coefficient: 1));
    _fb.deleteDebt(id);
    addNotification(
      type: 'debt_deleted',
      title: 'Đã xoá công nợ · ${cust.name}',
      body: '${fmt(d.amount)}đ · Xoá bởi $currentUserName',
    );
  }

  // ── Inventory mutations → Firebase ───────────────────────────────────────────
  void addInventoryEntry(InventoryEntry e) { _fb.addInventoryEntry(e); }
  void deleteInventoryEntry(String id)     { _fb.deleteInventoryEntry(id); }

  // ── Inventory helpers ────────────────────────────────────────────────────────
  double totalNhap(String sfId) =>
      inventoryEntries.where((e) => e.sfId == sfId && e.type == 'nhap').fold(0.0, (s, e) => s + e.qty);
  double totalXuat(String sfId) =>
      inventoryEntries.where((e) => e.sfId == sfId && e.type == 'xuat').fold(0.0, (s, e) => s + e.qty);
  double tonKho(String sfId) => totalNhap(sfId) - totalXuat(sfId);
}
