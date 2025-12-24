import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import '../config/api.dart';

class ProductService {
  /// Fetch products with optional search and category filter
  /// GET /products?search=...&category_id=...
  static Future<List<Product>> getProducts({
    String? search,
    int? categoryId,
  }) async {
    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (categoryId != null) {
      queryParams['category_id'] = categoryId.toString();
    }

    final uri = Uri.parse('${Api.baseUrl}/products').replace(
      queryParameters: queryParams.isNotEmpty ? queryParams : null,
    );

    final res = await http.get(
      uri,
      headers: {'Accept': 'application/json'},
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal load produk');
    }

    final jsonData = json.decode(res.body);
    final List list = jsonData['data'];

    return list.map((e) => Product.fromJson(e)).toList();
  }

  static Future<void> deleteProduct(int id, String? token) async {
    final headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.delete(
      Uri.parse('${Api.baseUrl}/products/$id'),
      headers: headers,
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      final body = res.body;
      // ignore: avoid_print
      print('deleteProduct failed: ${res.statusCode} - $body');
      throw Exception('Gagal menghapus produk (${res.statusCode}): $body');
    }
  }

  static Future<void> createProduct(Map<String, dynamic> data, String? token) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.post(
      Uri.parse('${Api.baseUrl}/products'),
      headers: headers,
      body: json.encode(data),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      // include response body for easier debugging (e.g. 401 details)
      final body = res.body;
      // print to console for developer debugging
      // ignore: avoid_print
      print('createProduct failed: ${res.statusCode} - $body');
      throw Exception('Gagal membuat produk (${res.statusCode}): $body');
    }
  }

  static Future<void> updateProduct(int id, Map<String, dynamic> data, String? token) async {
    final headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };

    final res = await http.put(
      Uri.parse('${Api.baseUrl}/products/$id'),
      headers: headers,
      body: json.encode(data),
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      final body = res.body;
      // ignore: avoid_print
      print('updateProduct failed: ${res.statusCode} - $body');
      throw Exception('Gagal update produk (${res.statusCode}): $body');
    }
  }

  /// Import products via CSV/TXT file (multipart)
  static Future<int> importProducts({
    required List<int> fileBytes,
    required String filename,
    String? token,
  }) async {
    final uri = Uri.parse('${Api.baseUrl}/products/import');
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    request.files.add(http.MultipartFile.fromBytes('file', fileBytes, filename: filename));

    final streamed = await request.send();
    final res = await http.Response.fromStream(streamed);
    if (res.statusCode != 200) {
      throw Exception('Gagal import produk (${res.statusCode}): ${res.body}');
    }
    final data = json.decode(res.body) as Map<String, dynamic>;
    return (data['created'] ?? 0) as int;
  }
}
