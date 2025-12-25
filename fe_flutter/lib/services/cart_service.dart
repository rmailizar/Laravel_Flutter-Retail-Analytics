import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'package:dio/dio.dart';

import '../config/api.dart';

class CartService {
  static Future<String> createCart(String? token) async {
    final res = await http.post(
      Uri.parse('${Api.baseUrl}/carts'),
      headers: {
        ...Api.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 201 && res.statusCode != 200) {
      throw Exception('Gagal membuat cart: ${res.body}');
    }

    final jsonData = json.decode(res.body);
    return jsonData['data']['code'];
  }

  static Future<Map<String, dynamic>> getCart(
      String code, String? token) async {
    final res = await http.get(
      Uri.parse('${Api.baseUrl}/carts/$code'),
      headers: {
        ...Api.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal ambil cart: ${res.body}');
    }

    return json.decode(res.body) as Map<String, dynamic>;
  }

  static Future<void> addItem(
      String code, String sku, int qty, String? token) async {
    final res = await http.post(
      Uri.parse('${Api.baseUrl}/carts/$code/items'),
      headers: {
        ...Api.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'sku': sku, 'qty': qty}),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal tambah item: ${res.body}');
    }
  }

  static Future<void> updateItem(
      String code, int itemId, int qty, String? token) async {
    final res = await http.put(
      Uri.parse('${Api.baseUrl}/carts/$code/items/$itemId'),
      headers: {
        ...Api.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'qty': qty}),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Gagal update item: ${res.body}');
    }
  }

  static Future<void> removeItem(String code, int itemId, String? token) async {
    final res = await http.delete(
      Uri.parse('${Api.baseUrl}/carts/$code/items/$itemId'),
      headers: {
        ...Api.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200 && res.statusCode != 204) {
      throw Exception('Gagal hapus item: ${res.body}');
    }
  }

  static Future<Map<String, dynamic>> checkout(
      String code, double cashPaid, String? token) async {
    final res = await http.post(
      Uri.parse('${Api.baseUrl}/carts/$code/checkout'),
      headers: {
        ...Api.headers,
        if (token != null) 'Authorization': 'Bearer $token',
      },
      body: json.encode({'cash_paid': cashPaid}),
    );

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Checkout gagal: ${res.body}');
    }

    return json.decode(res.body) as Map<String, dynamic>;
  }

  // ===============================
  // RECEIPT (PDF)
  // ===============================

  /// Ambil PDF sebagai bytes (dipakai untuk WEB / PRINTING)
  static Future<List<int>> getReceiptBytes(
    String invoice,
    String? token,
  ) async {
    final res = await http.get(
      Uri.parse('${Api.baseUrl}/transactions/$invoice/receipt'),
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('Gagal ambil receipt: ${res.body}');
    }

    return res.bodyBytes;
  }

  /// ANDROID ONLY
  /// Download PDF → simpan → buka
  static Future<String> downloadReceiptAndroid({
    required String invoice,
    required String token,
  }) async {
    final dio = Dio();

    // 📂 Folder storage aplikasi (AMAN Android 10+)
    final dir = await getExternalStorageDirectory();
    if (dir == null) {
      throw Exception('Storage tidak tersedia');
    }

    final filePath = '${dir.path}/struk-$invoice.pdf';

    // 🌐 Request PDF ke Laravel
    final response = await dio.get(
      Api.receipt(invoice), // 🔥 PAKAI BASEURL GLOBAL
      options: Options(
        responseType: ResponseType.bytes,
        headers: {
          ...Api.headers,
          'Authorization': 'Bearer $token',
          'Accept': 'application/pdf',
        },
      ),
    );

    // 💾 Simpan file
    final file = File(filePath);
    await file.writeAsBytes(response.data);

    // 👀 Preview PDF (otomatis buka)
    await OpenFilex.open(filePath);

    // 🔁 Return path (buat SnackBar / log)
    return filePath;
  }
}
