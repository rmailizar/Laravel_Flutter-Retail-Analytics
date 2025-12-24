import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/receipt.dart';
import '../utils/auth.dart';

class ReceiptService {
  static const baseUrl = "http://127.0.0.1:8000/api";

  static Future<Receipt> getReceipt(int transactionId) async {
    final res = await http.get(
      Uri.parse("$baseUrl/transactions/$transactionId"),
      headers: {
        'Authorization': 'Bearer ${Auth.token}',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode != 200) {
      throw Exception("Gagal ambil struk");
    }

    return Receipt.fromJson(jsonDecode(res.body));
  }
}
