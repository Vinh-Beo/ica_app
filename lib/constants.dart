import 'package:flutter/material.dart';
import 'models.dart';

// ── Colors ────────────────────────────────────────────────────────────────────
const Color kNavy   = Color(0xFF0A3D62);
const Color kTeal   = Color(0xFF0E7C8C);
const Color kTeal2  = Color(0xFF13A4B8);
const Color kInk    = Color(0xFF0F2C3F);
const Color kBg     = Color(0xFFF5F7F8);
const Color kPurple = Color(0xFF7C3AED);
const Color kPink   = Color(0xFFEC4899);

// ── Gradient tím → hồng (nút, nav active, lưu báo giá) ──
const LinearGradient kGradPP = LinearGradient(
  colors: [Color(0xFF7C3AED), Color(0xFFEC4899)],
  begin: Alignment.topLeft, end: Alignment.bottomRight,
);
// Gradient nền cho các màn đăng nhập
const LinearGradient kAuthGrad = LinearGradient(
  colors: [Color(0xFF7C3AED), Color(0xFFA855F7), Color(0xFFEC4899)],
  begin: Alignment.topCenter, end: Alignment.bottomCenter,
);

// ── Bảng màu theo light/dark (đọc từ Theme.of(context).brightness) ──
class AppPalette {
  final Color bg, surface, surface2, border, textMain, textMuted, text2, navy, teal;
  const AppPalette({
    required this.bg, required this.surface, required this.surface2,
    required this.border, required this.textMain, required this.textMuted,
    required this.text2, required this.navy, required this.teal,
  });

  static const light = AppPalette(
    bg: Color(0xFFF5F7F8), surface: Color(0xFFFFFFFF), surface2: Color(0xFFF1F5F9),
    border: Color(0xFFE2E8F0), textMain: Color(0xFF0F2C3F), textMuted: Color(0xFF94A3B8),
    text2: Color(0xFF64748B), navy: Color(0xFF0A3D62), teal: Color(0xFF0E7C8C),
  );
  static const dark = AppPalette(
    bg: Color(0xFF0F172A), surface: Color(0xFF1E293B), surface2: Color(0xFF334155),
    border: Color(0xFF334155), textMain: Color(0xFFE2E8F0), textMuted: Color(0xFF94A3B8),
    text2: Color(0xFFCBD5E1), navy: Color(0xFF3B82F6), teal: Color(0xFF2DD4BF),
  );

  static AppPalette of(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}

// Tiện ích: context.p  →  bảng màu hiện tại
extension PaletteX on BuildContext {
  AppPalette get p => AppPalette.of(this);
}

// ── Data constants ─────────────────────────────────────────────────────────────
const List<String> kMonths = [
  'Tháng 1','Tháng 2','Tháng 3','Tháng 4','Tháng 5','Tháng 6',
  'Tháng 7','Tháng 8','Tháng 9','Tháng 10','Tháng 11','Tháng 12',
];

const Map<String, String> kCatIcons = {
  'Tôm': '🦐', 'Cua': '🦀', 'Mực': '🦑', 'Cá': '🐠', 'Sò': '🐚', 'Khác': '🐡',
};

class CustTypeStyle {
  final IconData icon;
  final Color color;
  const CustTypeStyle(this.icon, this.color);
}

const Map<String, CustTypeStyle> kTypeIcon = {
  'Nhà hàng':    CustTypeStyle(Icons.restaurant_rounded,        Color(0xFF0E7C8C)),
  'Siêu thị':    CustTypeStyle(Icons.store_rounded,             Color(0xFF7C3AED)),
  'Chợ đầu mối': CustTypeStyle(Icons.warehouse_rounded,         Color(0xFFB45309)),
  'Khách lẻ':    CustTypeStyle(Icons.person_rounded,            Color(0xFF15803D)),
  'Đại lý':      CustTypeStyle(Icons.handshake_rounded,         Color(0xFF0A3D62)),
  'Xuất khẩu':   CustTypeStyle(Icons.flight_takeoff_rounded,    Color(0xFFEC4899)),
};

const List<String> kCustomerTypes = ['Nhà hàng','Siêu thị','Chợ đầu mối','Khách lẻ','Đại lý','Xuất khẩu'];
const List<String> kSeafoodUnits  = ['kg', 'con', 'hộp', 'thùng', 'tấn'];
const List<String> kCategories    = ['Tôm', 'Cua', 'Mực', 'Cá', 'Sò', 'Khác'];

// ── Initial data ──────────────────────────────────────────────────────────────
final List<Customer> kInitCustomers = [
  Customer(id: '1', name: 'Cửa hàng Hải Sản Hùng Vương', type: 'Nhà hàng',    coefficient: 1.35),
  Customer(id: '2', name: 'Nhà hàng Biển Đông',           type: 'Nhà hàng',    coefficient: 1.07),
  Customer(id: '3', name: 'Siêu thị Biển Xanh',           type: 'Siêu thị',    coefficient: 1.20),
  Customer(id: '4', name: 'Chợ Đầu Mối Miền Nam',         type: 'Chợ đầu mối', coefficient: 1.10),
  Customer(id: '5', name: 'Khách lẻ',                     type: 'Khách lẻ',    coefficient: 1.50),
  Customer(id: '6', name: 'Đại lý Phú Quốc',              type: 'Đại lý',      coefficient: 1.15),
];

final List<Seafood> kInitSeafood = [
  Seafood(id: '1', name: 'Cá Hồi Na Uy',     unit: 'kg',  icon: '🐟', category: 'Cá',  basePrice: 333000),
  Seafood(id: '2', name: 'Tôm Hùm Bông',     unit: 'kg',  icon: '🦞', category: 'Tôm', basePrice: 925000),
  Seafood(id: '3', name: 'Bào Ngư Hàn Quốc', unit: 'con', icon: '🐚', category: 'Sò',  basePrice: 79000),
  Seafood(id: '4', name: 'Cua Biển',         unit: 'kg',  icon: '🦀', category: 'Cua', basePrice: 280000),
  Seafood(id: '5', name: 'Mực Ống',          unit: 'kg',  icon: '🦑', category: 'Mực', basePrice: 180000),
];

// ── Formatters ────────────────────────────────────────────────────────────────
String fmt(double n) {
  final s = n.round().toString();
  final buf = StringBuffer();
  final len = s.length;
  for (int i = 0; i < len; i++) {
    if (i > 0 && (len - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}

String fmtK(double n) {
  final k = n / 1000;
  return '${k % 1 == 0 ? k.toStringAsFixed(0) : k.toStringAsFixed(1)}k';
}

String fmtDate(String? d) {
  if (d == null || d.isEmpty) return '—';
  final parts = d.split('-');
  if (parts.length < 3) return d;
  return '${parts[2]}/${parts[1]}/${parts[0]}';
}

String fmtDateShort(String? d) {
  if (d == null || d.isEmpty) return '—';
  final parts = d.split('-');
  if (parts.length < 3) return d;
  return '${parts[2]}/${parts[1]}';
}

String todayStr() {
  final n = DateTime.now();
  return '${n.year}-${n.month.toString().padLeft(2,'0')}-${n.day.toString().padLeft(2,'0')}';
}

String uid() => DateTime.now().millisecondsSinceEpoch.toString();
