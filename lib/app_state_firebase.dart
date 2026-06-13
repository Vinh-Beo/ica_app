// lib/app_state_firebase.dart
//
// VÍ DỤ tích hợp AppState với Firebase (thay cho app_state.dart in-memory).
// Dùng StreamSubscription để lắng nghe realtime từ Firestore — mọi thiết bị
// đăng nhập cùng tài khoản sẽ thấy dữ liệu đồng bộ ngay lập tức.
//
// Để dùng: đổi import trong main.dart từ 'app_state.dart' sang file này,
// hoặc copy nội dung đè lên app_state.dart.

import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'models.dart';
import 'services/firebase_service.dart';

class AppState extends ChangeNotifier {
  final _fb = FirebaseService.instance;

  // ── dữ liệu realtime ──
  List<Customer> customers = [];
  List<Seafood> seafood = [];
  List<Quote> quotes = [];
  List<DebtRecord> debts = [];
  List<InventoryEntry> inventory = [];
  List<AppNotification> notifications = [];

  bool loading = true;

  // ── subscriptions ──
  final List<StreamSubscription> _subs = [];

  AppState() {
    _bind();
  }

  /// Gắn các stream Firestore. Gọi lại sau khi đăng nhập.
  void _bind() {
    _clear();
    if (!_fb.isLoggedIn) {
      loading = false;
      notifyListeners();
      return;
    }
    loading = true;
    notifyListeners();

    _subs.add(_fb.watchCustomers().listen((d) {
      customers = d;
      notifyListeners();
    }));
    _subs.add(_fb.watchSeafood().listen((d) {
      seafood = d;
      notifyListeners();
    }));
    _subs.add(_fb.watchQuotes().listen((d) {
      quotes = d;
      notifyListeners();
    }));
    _subs.add(_fb.watchDebts().listen((d) {
      debts = d;
      notifyListeners();
    }));
    _subs.add(_fb.watchInventory().listen((d) {
      inventory = d;
      notifyListeners();
    }));
    _subs.add(_fb.watchNotifications().listen((d) {
      notifications = d;
      loading = false;
      notifyListeners();
    }));
  }

  void _clear() {
    for (final s in _subs) {
      s.cancel();
    }
    _subs.clear();
    customers = [];
    seafood = [];
    quotes = [];
    debts = [];
    inventory = [];
    notifications = [];
  }

  void rebindAfterLogin() => _bind();

  // ════════════════════════════════════════════════════════════════════════════
  //  Wrappers gọi FirebaseService — UI gọi các hàm này
  // ════════════════════════════════════════════════════════════════════════════

  // Customers
  Future<void> addCustomer(Customer c, {Uint8List? avatar}) =>
      _fb.addCustomer(c, avatarBytes: avatar);
  Future<void> updateCoefficient(String id, double coeff) =>
      _fb.updateCoefficient(id, coeff);
  Future<void> deleteCustomer(String id) => _fb.deleteCustomer(id);

  // Seafood
  Future<void> addSeafood(Seafood s) => _fb.addSeafood(s);
  Future<void> updateBasePrice(String id, double price) =>
      _fb.updateBasePrice(id, price);
  Future<void> deleteSeafood(String id) => _fb.deleteSeafood(id);

  // Quotes
  Future<void> saveQuote(Quote q) => _fb.addQuote(q);
  Future<void> deleteQuote(String id) => _fb.deleteQuote(id);

  // Debts (đều tự push thông báo bên trong service)
  Future<void> addDebt(DebtRecord d, {Uint8List? image}) =>
      _fb.addDebt(d, imageBytes: image);
  Future<void> updateDebt(DebtRecord d, {dynamic imageAction}) =>
      _fb.updateDebt(d, imageAction: imageAction);
  Future<void> addImageToDebt(String id, Uint8List bytes) =>
      _fb.addImageToDebt(id, bytes);
  Future<void> markDebtPaid(String id, double amount) =>
      _fb.markDebtPaid(id, amount);
  Future<void> deleteDebt(String id) => _fb.deleteDebt(id);

  // Inventory
  Future<void> addInventoryEntry(InventoryEntry e) =>
      _fb.addInventoryEntry(e);
  Future<void> deleteInventoryEntry(String id) =>
      _fb.deleteInventoryEntry(id);

  // Notifications
  Future<void> markNotificationRead(String id) =>
      _fb.markNotificationRead(id);
  Future<void> markAllRead() => _fb.markAllNotificationsRead();
  Future<void> deleteNotification(String id) =>
      _fb.deleteNotification(id);
  Future<void> clearNotifications() => _fb.clearNotifications();

  int get unreadCount => notifications.where((n) => !n.read).length;

  // ── Inventory helpers ──
  double totalNhap(String sfId) =>
      inventory.where((e) => e.sfId == sfId && e.type == 'nhap').fold(0, (s, e) => s + e.qty);
  double totalXuat(String sfId) =>
      inventory.where((e) => e.sfId == sfId && e.type == 'xuat').fold(0, (s, e) => s + e.qty);
  double tonKho(String sfId) => totalNhap(sfId) - totalXuat(sfId);

  @override
  void dispose() {
    _clear();
    super.dispose();
  }
}
