import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/stock_service.dart';
import '../../models/product.dart';

class StockAdjustScreen extends StatefulWidget {
  final Product product;
  const StockAdjustScreen({super.key, required this.product});

  @override
  State<StockAdjustScreen> createState() => _StockAdjustScreenState();
}

class _StockAdjustScreenState extends State<StockAdjustScreen> {
  final _formKey = GlobalKey<FormState>();
  String _type = 'in';
  final _qtyCtrl = TextEditingController(text: '1');
  final _noteCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _qtyCtrl.dispose();
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final token = context.read<AuthProvider>().token;
      final newStock = await StockService.adjustStock(
        productId: widget.product.id,
        type: _type,
        qty: int.parse(_qtyCtrl.text),
        note: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
        token: token,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Stok berhasil diubah. Stok baru: $newStock'),
          backgroundColor: Colors.green.shade600,
        ),
      );
      Navigator.pop(context, newStock);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal adjust stok: $e'),
          backgroundColor: Colors.red.shade600,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Adjust Stok'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.product.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _type,
                items: const [
                  DropdownMenuItem(value: 'in', child: Text('Tambah (in)')),
                  DropdownMenuItem(value: 'out', child: Text('Kurangi (out)')),
                  DropdownMenuItem(value: 'adjust', child: Text('Sesuaikan (adjust)')),
                ],
                onChanged: (v) => setState(() => _type = v ?? 'in'),
                decoration: const InputDecoration(labelText: 'Jenis Perubahan'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _qtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Jumlah'),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n <= 0) return 'Qty harus >= 1';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _noteCtrl,
                decoration: const InputDecoration(labelText: 'Catatan (opsional)'),
                maxLines: 3,
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  child: _isSubmitting
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text('Simpan'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
