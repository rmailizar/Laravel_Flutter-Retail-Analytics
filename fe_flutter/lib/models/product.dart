class Product {
  final int id;
  final String name;
  final String sku;
  final String? barcode;
  final double sellPrice;
  final double costPrice;
  final int stock;
  final bool active;
  final int? categoryId;

  Product({
    required this.id,
    required this.name,
    required this.sku,
    this.barcode,
    required this.sellPrice,
    required this.costPrice,
    required this.stock,
    required this.active,
    this.categoryId,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      sku: json['sku'],
      barcode: json['barcode']?.toString(),
      sellPrice: double.parse(json['sell_price'].toString()),
      costPrice: double.parse(json['cost_price'].toString()),
      stock: json['stock'],
      active: json['active'] == 1 || json['active'] == true,
      categoryId: json['category_id'],
    );
  }
}
