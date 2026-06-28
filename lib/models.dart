import 'dart:typed_data';
import 'package:flutter/material.dart';

// ════════════════════════════════════════════════════════════════════════════
//  Tất cả model đều có toMap() / fromMap() để lưu & đọc Firestore.
//  Ảnh KHÔNG lưu trong Firestore — chỉ lưu URL (imageUrl/avatarUrl) trỏ tới
//  Firebase Storage. Bytes ảnh (imageBytes) chỉ dùng tạm khi chọn ảnh mới.
// ════════════════════════════════════════════════════════════════════════════

// ── Customer ──────────────────────────────────────────────────────────────────
class Customer {
  final String id;
  String name;
  String type;
  double coefficient;
  String? avatarUrl;
  String? address;
  String? taxCode;

  Customer({
    required this.id,
    required this.name,
    required this.type,
    required this.coefficient,
    this.avatarUrl,
    this.address,
    this.taxCode,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'coefficient': coefficient,
        'avatarUrl': avatarUrl,
        'address': address,
        'taxCode': taxCode,
      };

  factory Customer.fromMap(String id, Map<String, dynamic> m) => Customer(
        id: id,
        name: m['name'] ?? '',
        type: m['type'] ?? 'Khách lẻ',
        coefficient: (m['coefficient'] ?? 1.0).toDouble(),
        avatarUrl: m['avatarUrl'],
        address: m['address'],
        taxCode: m['taxCode'],
      );

  Customer copyWith({
    String? name, String? type, double? coefficient,
    String? avatarUrl, String? address, String? taxCode,
  }) => Customer(
        id: id,
        name: name ?? this.name,
        type: type ?? this.type,
        coefficient: coefficient ?? this.coefficient,
        avatarUrl: avatarUrl ?? this.avatarUrl,
        address: address ?? this.address,
        taxCode: taxCode ?? this.taxCode,
      );
}

// ── Seafood ───────────────────────────────────────────────────────────────────
class Seafood {
  final String id;
  String name;
  String unit;
  String icon;
  String category;
  double basePrice;

  Seafood({
    required this.id,
    required this.name,
    required this.unit,
    required this.icon,
    required this.category,
    required this.basePrice,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'unit': unit,
        'icon': icon,
        'category': category,
        'basePrice': basePrice,
      };

  factory Seafood.fromMap(String id, Map<String, dynamic> m) => Seafood(
        id: id,
        name: m['name'] ?? '',
        unit: m['unit'] ?? 'kg',
        icon: m['icon'] ?? '🐡',
        category: m['category'] ?? 'Khác',
        basePrice: (m['basePrice'] ?? 0).toDouble(),
      );

  Seafood copyWith({String? name, String? unit, String? icon, String? category, double? basePrice}) =>
      Seafood(
        id: id,
        name: name ?? this.name,
        unit: unit ?? this.unit,
        icon: icon ?? this.icon,
        category: category ?? this.category,
        basePrice: basePrice ?? this.basePrice,
      );
}

// ── Quote ─────────────────────────────────────────────────────────────────────
class QuoteItem {
  final String id;
  final String name;
  final String unit;
  final String icon;
  final double basePrice;
  final double sellPrice;

  const QuoteItem({
    required this.id,
    required this.name,
    required this.unit,
    required this.icon,
    required this.basePrice,
    required this.sellPrice,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'unit': unit,
        'icon': icon,
        'basePrice': basePrice,
        'sellPrice': sellPrice,
      };

  factory QuoteItem.fromMap(Map<String, dynamic> m) => QuoteItem(
        id: m['id'] ?? '',
        name: m['name'] ?? '',
        unit: m['unit'] ?? 'kg',
        icon: m['icon'] ?? '🐡',
        basePrice: (m['basePrice'] ?? 0).toDouble(),
        sellPrice: (m['sellPrice'] ?? 0).toDouble(),
      );
}

class Quote {
  final String id;
  final int month;
  final int year;
  final String customerName;
  final String customerType;
  final double coefficient;
  final List<QuoteItem> items;
  final String createdAt;

  const Quote({
    required this.id,
    required this.month,
    required this.year,
    required this.customerName,
    required this.customerType,
    required this.coefficient,
    required this.items,
    required this.createdAt,
  });

  double get totalBase => items.fold(0, (s, i) => s + i.basePrice);
  double get totalSell => items.fold(0, (s, i) => s + i.sellPrice);
  double get profit => totalSell - totalBase;

  Map<String, dynamic> toMap() => {
        'month': month,
        'year': year,
        'customerName': customerName,
        'customerType': customerType,
        'coefficient': coefficient,
        'items': items.map((e) => e.toMap()).toList(),
        'createdAtStr': createdAt,
      };

  factory Quote.fromMap(String id, Map<String, dynamic> m) => Quote(
        id: id,
        month: m['month'] ?? 0,
        year: m['year'] ?? DateTime.now().year,
        customerName: m['customerName'] ?? '',
        customerType: m['customerType'] ?? '',
        coefficient: (m['coefficient'] ?? 1.0).toDouble(),
        items: (m['items'] as List? ?? [])
            .map((e) => QuoteItem.fromMap(Map<String, dynamic>.from(e)))
            .toList(),
        createdAt: m['createdAtStr'] ?? '',
      );
}

// ── Debt ──────────────────────────────────────────────────────────────────────
class DebtRecord {
  final String id;
  final String customerId;
  double amount;
  String deliveryDate;
  String createdDate;
  String? imageUrl;      // legacy: Firebase Storage URL
  String? imageBase64;   // base64 JPEG, lưu thẳng Firestore
  Uint8List? imageBytes; // tạm: bytes vừa pick, không lưu Firestore
  String note;
  bool isPaid;
  String? paidDate;
  String by;

  DebtRecord({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.deliveryDate,
    required this.createdDate,
    this.imageUrl,
    this.imageBase64,
    this.imageBytes,
    this.note = '',
    this.isPaid = false,
    this.paidDate,
    this.by = '',
  });

  bool get hasImage => imageBase64 != null || imageUrl != null || imageBytes != null;

  Map<String, dynamic> toMap() => {
        'customerId': customerId,
        'amount': amount,
        'deliveryDate': deliveryDate,
        'createdDate': createdDate,
        'imageUrl': imageUrl,
        'imageBase64': imageBase64,
        'note': note,
        'isPaid': isPaid,
        'paidDate': paidDate,
        'by': by,
      };

  factory DebtRecord.fromMap(String id, Map<String, dynamic> m) => DebtRecord(
        id: id,
        customerId: m['customerId'] ?? '',
        amount: (m['amount'] ?? 0).toDouble(),
        deliveryDate: m['deliveryDate'] ?? '',
        createdDate: m['createdDate'] ?? '',
        imageUrl: m['imageUrl'],
        imageBase64: m['imageBase64'],
        note: m['note'] ?? '',
        isPaid: m['isPaid'] ?? false,
        paidDate: m['paidDate'],
        by: m['by'] ?? '',
      );
}

// ── Inventory ─────────────────────────────────────────────────────────────────
class InventoryEntry {
  final String id;
  String type; // "nhap" | "xuat"
  String sfId;
  double qty;
  String date;

  InventoryEntry({
    required this.id,
    required this.type,
    required this.sfId,
    required this.qty,
    required this.date,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'sfId': sfId,
        'qty': qty,
        'date': date,
      };

  factory InventoryEntry.fromMap(String id, Map<String, dynamic> m) => InventoryEntry(
        id: id,
        type: m['type'] ?? 'nhap',
        sfId: m['sfId'] ?? '',
        qty: (m['qty'] ?? 0).toDouble(),
        date: m['date'] ?? '',
      );
}

// ── Notification ────────────────────────────────────────────────────────────────
class AppNotification {
  final String id;
  final String type;   // debt_new | debt_paid | quote | system
  final String title;
  final String body;
  final int ts;        // millisecondsSinceEpoch
  bool read;
  final int deviceCount;
  final String by;     // người tạo (tên user)

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.ts,
    this.read = false,
    this.deviceCount = 0,
    this.by = '',
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'title': title,
        'body': body,
        'ts': ts,
        'read': read,
        'deviceCount': deviceCount,
        'by': by,
      };

  factory AppNotification.fromMap(String id, Map<String, dynamic> m) => AppNotification(
        id: id,
        type: m['type'] ?? 'system',
        title: m['title'] ?? '',
        body: m['body'] ?? '',
        ts: m['ts'] ?? 0,
        read: m['read'] ?? false,
        deviceCount: m['deviceCount'] ?? 0,
        by: m['by'] ?? '',
      );
}

// ── Auth User ─────────────────────────────────────────────────────────────────
class AppUser {
  final String name;
  final String email;
  const AppUser({required this.name, required this.email});
}

// ── Price Level ───────────────────────────────────────────────────────────────
enum PriceLevelType { loss, low, normal, profit }

class PriceLevel {
  final PriceLevelType type;
  final String label;
  final Color color;
  final Color bg;
  const PriceLevel({required this.type, required this.label, required this.color, required this.bg});
}

PriceLevel getPriceLevel(double ratio) {
  if (ratio < 1.0)  return const PriceLevel(type: PriceLevelType.loss,   label: 'Lỗ',          color: Color(0xFFDC2626), bg: Color(0xFFFEE2E2));
  if (ratio < 1.15) return const PriceLevel(type: PriceLevelType.low,    label: 'Lãi thấp',    color: Color(0xFFB45309), bg: Color(0xFFFEF3C7));
  if (ratio < 1.30) return const PriceLevel(type: PriceLevelType.normal, label: 'Bình thường', color: Color(0xFF0E7490), bg: Color(0xFFCFFAFE));
  return               const PriceLevel(type: PriceLevelType.profit, label: 'Lãi cao',    color: Color(0xFF15803D), bg: Color(0xFFDCFCE7));
}
