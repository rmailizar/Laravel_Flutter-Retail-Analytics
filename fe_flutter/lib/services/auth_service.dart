import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';

class AuthService {
  // Returns parsed JSON on success, otherwise null
  static Future<Map<String, dynamic>?> login(String email, String password) async {
    final response = await http.post(
      Uri.parse(Api.login),
      headers: {
        "Accept": "application/json",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      try {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        return null;
      }
    }

    return null;
  }



static Future<bool> register(
  String name,
  String email,
  String password, {
  String role = 'cashier',
}) async {
  final response = await http.post(
    Uri.parse("${Api.baseUrl}/register"),
    headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "name": name,
      "email": email,
      "password": password,
      "password_confirmation": password,
      "role": role,
    }),
  );

  return response.statusCode == 200 || response.statusCode == 201;
}


}
