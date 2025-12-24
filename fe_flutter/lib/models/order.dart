// Helper function to parse numeric values that might be strings
double _parseDouble(dynamic value) {
  if (value == null) return 0.0;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? 0.0;
  return 0.0;
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}

class Order {
  final int id;
  final String invoiceNumber;
  final double totalAmount;
  final double cashPaid;
  final double changeAmount;
  final String transactionDate;
  final String createdAt;
  final List<OrderItem>? items;

  Order({
    required this.id,
    required this.invoiceNumber,
    required this.totalAmount,
    required this.cashPaid,
    required this.changeAmount,
    required this.transactionDate,
    required this.createdAt,
    this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: _parseInt(json['id']),
      invoiceNumber: json['invoice_number'] ?? '',
      totalAmount: _parseDouble(json['total_amount']),
      cashPaid: _parseDouble(json['cash_paid']),
      changeAmount: _parseDouble(json['change_amount']),
      transactionDate: json['transaction_date'] ?? '',
      createdAt: json['created_at'] ?? '',
      items: json['items'] != null 
        ? (json['items'] as List).map((e) => OrderItem.fromJson(e)).toList()
        : null,
    );
  }
}

class OrderItem {
  final int id;
  final int productId;
  final String productName;
  final int qty;
  final double price;
  final double subtotal;

  OrderItem({
    required this.id,
    required this.productId,
    required this.productName,
    required this.qty,
    required this.price,
    required this.subtotal,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Handle null product - use product_id as fallback
    final productName = json['product']?['name'] ?? 'Produk #${json['product_id'] ?? '?'}';
    
    return OrderItem(
      id: _parseInt(json['id']),
      productId: _parseInt(json['product_id']),
      productName: productName,
      qty: _parseInt(json['qty']),
      price: _parseDouble(json['price']),
      subtotal: _parseDouble(json['subtotal']),
    );
  }
}
