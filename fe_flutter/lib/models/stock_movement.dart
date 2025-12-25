class StockMovement {
  final int id;
  final int productId;
  final String type;
  final int qty;
  final String? note;
  final int? referenceId;
  final int? createdBy;
  final String? createdAt;
  final String? userName;
  final String? productName;

  StockMovement({
    required this.id,
    required this.productId,
    required this.type,
    required this.qty,
    this.note,
    this.referenceId,
    this.createdBy,
    this.createdAt,
    this.userName,
    this.productName,
  });

  factory StockMovement.fromJson(Map<String, dynamic> json) {
    return StockMovement(
      id: json['id'],
      productId: json['product_id'],
      type: json['type'],
      qty: json['qty'],
      note: json['note'],
      referenceId: json['reference_id'],
      createdBy: json['created_by'],
      createdAt: json['created_at'],
      userName: json['user'] != null ? (json['user']['name'] ?? '') : null,
      productName: json['product'] != null ? (json['product']['name'] ?? '') : null,
    );
  }
}
