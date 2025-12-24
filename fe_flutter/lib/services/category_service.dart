import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api.dart';
import '../models/category.dart';

class CategoryService {
  /// Fetch all categories from API
  /// GET /categories
  static Future<List<Category>> getCategories() async {
    final res = await http.get(
      Uri.parse('${Api.baseUrl}/categories'),
      headers: {'Accept': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal load kategori: ${res.body}');
    }

    final jsonData = json.decode(res.body);
    
    // API returns { success: true, data: [...] }
    final List list = jsonData['data'] ?? [];
    return list.map((e) => Category.fromJson(e)).toList();
  }

  /// Create a new category (Admin only)
  /// POST /categories
  static Future<Category> createCategory(String name, String? token) async {
    final res = await http.post(
      Uri.parse('${Api.baseUrl}/categories'),
      headers: {
        ...Api.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'name': name}),
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Gagal membuat kategori: ${res.body}');
    }

    final jsonData = json.decode(res.body);
    return Category.fromJson(jsonData['data']);
  }

  /// Update category (Admin only)
  /// PUT /categories/{id}
  static Future<Category> updateCategory(int id, String name, String? token) async {
    final res = await http.put(
      Uri.parse('${Api.baseUrl}/categories/$id'),
      headers: {
        ...Api.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'name': name}),
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal update kategori: ${res.body}');
    }

    final jsonData = json.decode(res.body);
    return Category.fromJson(jsonData['data']);
  }

  /// Delete category (Admin only)
  /// DELETE /categories/{id}
  static Future<void> deleteCategory(int id, String? token) async {
    final res = await http.delete(
      Uri.parse('${Api.baseUrl}/categories/$id'),
      headers: {
        ...Api.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Gagal hapus kategori: ${res.body}');
    }
  }
}
