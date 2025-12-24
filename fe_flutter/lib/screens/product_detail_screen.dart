import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/stock_service.dart';
import '../models/stock_movement.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  final bool isAdmin;

  const ProductDetailScreen({
    super.key,
    required this.product,
    this.isAdmin = false,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  List<StockMovement>? _history;
  bool _loadingHistory = false;
  String? _historyError;

  @override
  void initState() {
    super.initState();
    if (widget.isAdmin) _loadStockHistory();
  }

  Future<void> _loadStockHistory() async {
    setState(() {
      _loadingHistory = true;
      _historyError = null;
    });
    try {
      final token = null; // TODO: ambil token dari Provider jika perlu
      final history = await StockService.getStockHistory(
          productId: widget.product.id, token: token);
      setState(() => _history = history);
    } catch (e) {
      setState(() => _historyError = e.toString());
    } finally {
      setState(() => _loadingHistory = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF2DD4BF)],
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.shopping_bag_outlined,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.product.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'SKU: ${widget.product.sku}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Barcode
                    _buildInfoRow(
                      icon: Icons.qr_code_rounded,
                      label: 'Barcode',
                      value: widget.product.barcode ?? '-',
                      color: const Color(0xFF7C3AED),
                    ),
                    const SizedBox(height: 16),

                    // Stock
                    _buildInfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: 'Stok',
                      value: '${widget.product.stock} item',
                      color: widget.product.stock > 10
                          ? Colors.green
                          : widget.product.stock > 0
                              ? Colors.orange
                              : Colors.red,
                    ),
                    const SizedBox(height: 16),

                    // Prices Section (Admin only)
                    if (widget.isAdmin) ...[
                      const Divider(height: 32),
                      const Text(
                        'Harga',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.money_outlined,
                        label: 'Harga Modal',
                        value: 'Rp ${_formatPrice(widget.product.costPrice)}',
                        color: Colors.grey,
                      ),
                      const SizedBox(height: 16),
                    ],

                    // Sell Price
                    _buildInfoRow(
                      icon: Icons.sell_outlined,
                      label: 'Harga Jual',
                      value: 'Rp ${_formatPrice(widget.product.sellPrice)}',
                      color: const Color(0xFF2DD4BF),
                    ),

                    // Profit Margin (Admin only)
                    if (widget.isAdmin) ...[
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        icon: Icons.trending_up_rounded,
                        label: 'Margin',
                        value: _calculateMargin(),
                        color: Colors.green,
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Status
                    _buildInfoRow(
                      icon: widget.product.active
                          ? Icons.check_circle_outline
                          : Icons.block_outlined,
                      label: 'Status',
                      value: widget.product.active ? 'Aktif' : 'Nonaktif',
                      color: widget.product.active ? Colors.green : Colors.grey,
                    ),
                    if (widget.isAdmin) ...[
                      const SizedBox(height: 24),
                      const Text('Riwayat Perubahan Stok', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 8),
                      _buildStockHistorySection(),
                    ],
                  ],
                ),
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF7C3AED),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Tutup',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    return intPrice.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  String _calculateMargin() {
    if (widget.product.costPrice == 0) return '-';
    final margin =
        ((widget.product.sellPrice - widget.product.costPrice) /
            widget.product.costPrice *
            100);
    return '${margin.toStringAsFixed(1)}%';
  }

  Widget _buildStockHistorySection() {
    if (_loadingHistory) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_historyError != null) {
      return Text('Gagal memuat riwayat: $_historyError', style: const TextStyle(color: Colors.red));
    }
    if (_history == null) {
      return const SizedBox();
    }
    if (_history!.isEmpty) {
      return const Text('Belum ada riwayat perubahan stok.');
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _history!.length,
      separatorBuilder: (_, __) => const Divider(height: 16),
      itemBuilder: (context, i) {
        final h = _history![i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              h.type == 'in'
                  ? Icons.add_circle_outline
                  : h.type == 'out'
                      ? Icons.remove_circle_outline
                      : Icons.edit,
              color: h.type == 'in'
                  ? Colors.green
                  : h.type == 'out'
                      ? Colors.red
                      : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${h.type.toUpperCase()} | ${h.qty} item',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  if (h.note != null && h.note!.isNotEmpty)
                    Text('Catatan: ${h.note}', style: const TextStyle(fontSize: 12)),
                  Text(
                    h.createdAt ?? '',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  if (h.userName != null && h.userName!.isNotEmpty)
                    Text('Oleh: ${h.userName}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
