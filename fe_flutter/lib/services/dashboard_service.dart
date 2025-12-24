import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getSummary() async {
    final res = await http.get(
      Uri.parse("${Api.baseUrl}/dashboard/summary"),
      headers: Api.headers,
    );

    return jsonDecode(res.body);
  }
}
