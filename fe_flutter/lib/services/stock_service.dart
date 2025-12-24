import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/stock_movement.dart';

class StockService {
  /// Adjust product stock: type in|out|adjust
  static Future<int> adjustStock({
    required int productId,
    required String type,
    required int qty,
    String? note,
    String? token,
  }) async {
    final res = await http.post(
      Uri.parse('${Api.baseUrl}/products/$productId/adjust-stock'),
      headers: {
        ...Api.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'type': type,
        'qty': qty,
        if (note != null && note.isNotEmpty) 'note': note,
      }),
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal adjust stok: ${res.body}');
    }

    final data = json.decode(res.body) as Map<String, dynamic>;
    return (data['new_stock'] ?? 0) as int;
  }

  static Future<List<StockMovement>> getStockHistory({
    required int productId,
    String? token,
  }) async {
    final res = await http.get(
      Uri.parse('${Api.baseUrl}/products/$productId/stock-history'),
      headers: {
        ...Api.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
    if (res.statusCode != 200) {
      throw Exception('Gagal mengambil history stok: \\${res.body}');
    }
    final data = json.decode(res.body);
    final List list = data['data'] ?? [];
    return list.map((e) => StockMovement.fromJson(e)).toList();
  }
}
