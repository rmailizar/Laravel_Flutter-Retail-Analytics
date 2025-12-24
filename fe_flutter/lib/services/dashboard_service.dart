import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class DashboardService {
  static Future<Map<String, dynamic>> getSummary({String? token}) async {
    print('📊 [DashboardService] Getting summary...');
    print('📊 [DashboardService] Token: ${token?.substring(0, 20)}...');
    
    final headers = {
      ...Api.headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final url = "${Api.baseUrl}/dashboard/summary";
    print('📊 [DashboardService] URL: $url');
    
    final res = await http.get(
      Uri.parse(url),
      headers: headers,
    );

    print('📊 [DashboardService] Status: ${res.statusCode}');
    print('📊 [DashboardService] Body: ${res.body}');

    if (res.statusCode != 200) {
      throw Exception('Gagal ambil summary: ${res.body}');
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    print('✅ [DashboardService] Parsed data: $data');
    return data;
  }

  static Future<List<dynamic>> getSalesChart({String? token}) async {
    final headers = {
      ...Api.headers,
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.get(
      Uri.parse("${Api.baseUrl}/dashboard/sales-chart"),
      headers: headers,
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal ambil sales chart: ${res.body}');
    }

    return jsonDecode(res.body) as List<dynamic>;
  }
}
