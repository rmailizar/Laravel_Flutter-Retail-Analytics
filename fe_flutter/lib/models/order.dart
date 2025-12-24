class Order {
  final int id;
  final int total;
  final String createdAt;

  Order({
    required this.id,
    required this.total,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      total: json['total'],
      createdAt: json['created_at'],
    );
  }
}
