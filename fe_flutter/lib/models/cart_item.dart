import 'product.dart';

class CartItem {
  final int id; // server cart item id
  final Product product;
  int qty;

  CartItem({
    required this.id,
    required this.product,
    required this.qty,
  });

  double get subtotal => qty * product.sellPrice;

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as int,
      product: Product.fromJson(json['product'] as Map<String, dynamic>),
      qty: json['qty'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'qty': qty,
    };
  }
}
