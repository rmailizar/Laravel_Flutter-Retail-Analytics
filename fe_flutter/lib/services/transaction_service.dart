import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/config.dart';

class TransactionService {
  static Future<void> checkout(
      String token, List<Map<String, dynamic>> items) async {
    final res = await http.post(
      Uri.parse("$baseUrl/transactions"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json"
      },
      body: jsonEncode({"items": items}),
    );

    if (res.statusCode != 200) {
      throw Exception(jsonDecode(res.body)['message']);
    }
  }
}
