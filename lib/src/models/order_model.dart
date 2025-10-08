enum OrderStatus {
  delivered,
  inProgress,
  cancelled,
}

class Order {
  final String id;
  final List<OrderItem> items;
  

  Order({
    required this.id,
    required this.items
  });
}

class OrderItem {
  final String name;
  final DateTime createTime;
  final DateTime updateTime;
  final DateTime delivery_time;
  final OrderStatus status;
  final String content;

  OrderItem({
    required this.delivery_time,
    required this.content, 
    required this.name,
    required this.createTime,
    required this.updateTime,
    required this.status
  });
}
