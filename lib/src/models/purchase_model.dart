enum PurchaseStatus {
  delivered,
  inProgress,
  cancelled,
}

class Purchase {
  final String id;
  final List<PurchaseItem> items;
  

  Purchase({
    required this.id,
    required this.items
  });
}

class PurchaseItem {
  final String name;
  final DateTime createTime;
  final DateTime updateTime;
  final PurchaseStatus status;
  final double weight;
  final double price;
  final double total; 

  PurchaseItem({
    required this.name,
    required this.createTime,
    required this.updateTime,
    required this.status,
    required this.weight,
    required this.price,
    required this.total
  });
}