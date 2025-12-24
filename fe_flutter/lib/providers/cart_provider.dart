import 'package:flutter/material.dart';
import '../models/product.dart';

class CartItem {
  final Product product;
  int qty;

  CartItem(this.product, this.qty);

  double get subtotal => product.sellPrice * qty;
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> items = [];

  void add(Product product) {
    final index = items.indexWhere((e) => e.product.id == product.id);

    if (index >= 0) {
      items[index].qty++;
    } else {
      items.add(CartItem(product, 1));
    }
    notifyListeners();
  }

  double get total =>
      items.fold(0.0, (sum, item) => sum + item.subtotal);

  void clear() {
    items.clear();
    notifyListeners();
  }
}
