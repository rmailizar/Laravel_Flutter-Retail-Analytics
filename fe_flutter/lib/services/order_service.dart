import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/order.dart';

class OrderService {
  // CREATE ORDER (sudah ada)
  static Future<void> createOrder(
    List items,
    int total,
    int cash,
  ) async {
    final body = {
      "total": total,
      "cash_received": cash,
      "items": items
          .map((e) => {
                "product_id": e.product.id,
                "qty": e.qty,
                "price": e.product.price,
              })
          .toList()
    };

    await http.post(
      Uri.parse("${Api.baseUrl}/orders"),
      headers: Api.headers,
      body: jsonEncode(body),
    );
  }

  // GET ORDER HISTORY
  static Future<List<Order>> getOrders() async {
    final res = await http.get(
      Uri.parse("${Api.baseUrl}/orders"),
      headers: Api.headers,
    );

    final data = jsonDecode(res.body);
    return (data as List).map((e) => Order.fromJson(e)).toList();
  }
}
