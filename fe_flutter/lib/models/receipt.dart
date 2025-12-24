class Receipt {
  final int id;
  final String cashier;
  final DateTime date;
  final List<ReceiptItem> items;
  final double total;
  final double paid;
  final double change;

  Receipt({
    required this.id,
    required this.cashier,
    required this.date,
    required this.items,
    required this.total,
    required this.paid,
    required this.change,
  });

  factory Receipt.fromJson(Map<String, dynamic> json) {
    return Receipt(
      id: json['id'],
      cashier: json['cashier'],
      date: DateTime.parse(json['created_at']),
      items: (json['items'] as List)
          .map((e) => ReceiptItem.fromJson(e))
          .toList(),
      total: double.parse(json['total'].toString()),
      paid: double.parse(json['paid'].toString()),
      change: double.parse(json['change'].toString()),
    );
  }
}

class ReceiptItem {
  final String name;
  final int qty;
  final double price;

  ReceiptItem({
    required this.name,
    required this.qty,
    required this.price,
  });

  factory ReceiptItem.fromJson(Map<String, dynamic> json) {
    return ReceiptItem(
      name: json['name'],
      qty: json['qty'],
      price: double.parse(json['price'].toString()),
    );
  }
}
