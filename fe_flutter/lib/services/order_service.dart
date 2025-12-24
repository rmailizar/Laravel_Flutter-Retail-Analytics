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
  static Future<List<Order>> getOrders({String? token}) async {
    final headers = {
      ...Api.headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    print('🔍 Fetching transactions from: ${Api.baseUrl}/transactions');
    print('🔑 Token: ${token?.substring(0, 20)}...');

    final res = await http.get(
      Uri.parse("${Api.baseUrl}/transactions"),
      headers: headers,
    );

    print('📡 Response status: ${res.statusCode}');
    print('📦 Response body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Gagal ambil transaksi: ${res.body}');
    }

    final data = jsonDecode(res.body);
    print('✅ Decoded data type: ${data.runtimeType}');
    
    // Handle pagination response
    final transactions = data['data'] ?? data;
    print('📋 Transactions type: ${transactions.runtimeType}');
    print('📊 Transactions count: ${transactions is List ? transactions.length : 0}');
    
    if (transactions is! List) {
      print('⚠️ Transactions is not a List!');
      return [];
    }
    
    final orders = transactions.map<Order>((e) {
      print('🔄 Parsing order: $e');
      return Order.fromJson(e);
    }).toList();
    
    print('✅ Parsed ${orders.length} orders');
    return orders;
  }
}
