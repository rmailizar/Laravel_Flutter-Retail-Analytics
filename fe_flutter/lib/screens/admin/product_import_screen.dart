import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';

class ProductImportScreen extends StatefulWidget {
  const ProductImportScreen({super.key});

  @override
  State<ProductImportScreen> createState() => _ProductImportScreenState();
}

class _ProductImportScreenState extends State<ProductImportScreen> {
  bool _isUploading = false;
  String? _lastResult;

  Future<void> _pickAndUpload() async {
    setState(() => _isUploading = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv', 'txt'],
        withData: true,
      );
      if (result == null || result.files.isEmpty) {
        setState(() => _isUploading = false);
        return;
      }
      final file = result.files.first;
      final bytes = file.bytes;
      if (bytes == null) {
        throw Exception('File tidak bisa dibaca');
      }

      final token = context.read<AuthProvider>().token;
      final created = await ProductService.importProducts(
        fileBytes: bytes as Uint8List,
        filename: file.name,
        token: token,
      );
      setState(() => _lastResult = 'Berhasil import $created produk');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_lastResult!), backgroundColor: Colors.green.shade600),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal import: $e'), backgroundColor: Colors.red.shade600),
      );
    } finally {
      setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Import Produk'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Format CSV:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('name,sku,barcode,category_id,sell_price,cost_price,stock'),
            const Text('Indomie Goreng,SKU001,BR001,1,3000,2500,100'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.file_upload_rounded),
                onPressed: _isUploading ? null : _pickAndUpload,
                label: Text(_isUploading ? 'Mengunggah...' : 'Pilih File dan Import'),
              ),
            ),
            if (_lastResult != null) ...[
              const SizedBox(height: 12),
              Text(_lastResult!),
            ],
          ],
        ),
      ),
    );
  }
}
