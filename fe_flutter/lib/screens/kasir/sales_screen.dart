import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:html' as html;

import '../../providers/auth_provider.dart';
import '../../widgets/app_header.dart';
import '../../models/product.dart';
import '../../models/category.dart';
import '../../models/cart_item.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';
import '../../services/cart_service.dart';
import '../../widgets/product_card.dart';
import '../product_detail_screen.dart';
import '../../widgets/cart_item_tile.dart';
import '../../widgets/category_filter.dart';
import '../../widgets/cart_summary.dart';
import '../login_screen.dart';
import 'scanner_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  // Data
  List<Product> _products = [];
  List<Category> _categories = [];
  List<CartItem> _cartItems = [];
  String? _cartCode;

  // State
  bool _isLoadingProducts = true;
  bool _isLoadingCategories = true;
  bool _isCheckingOut = false;
  int? _selectedCategoryId;
  String _searchQuery = '';
  final Set<int> _addingProductIds = {};
  final Set<int> _updatingItemIds = {};

  // Controllers
  final TextEditingController _cashController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _cashController.dispose();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await Future.wait([
      _loadProducts(),
      _loadCategories(),
      _createCart(),
    ]);
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoadingProducts = true);
    try {
      final products = await ProductService.getProducts(
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        categoryId: _selectedCategoryId,
      );
      if (!mounted) return;
      setState(() {
        _products = products;
        _isLoadingProducts = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingProducts = false);
      _showError('Gagal memuat produk: $e');
    }
  }

  Future<void> _loadCategories() async {
    setState(() => _isLoadingCategories = true);
    try {
      final categories = await CategoryService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
      // Categories are optional, just log
      debugPrint('Failed to load categories: $e');
    }
  }

  Future<void> _createCart() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;
    try {
      final code = await CartService.createCart(token);
      if (!mounted) return;
      setState(() => _cartCode = code);
    } catch (e) {
      debugPrint('Failed to create cart: $e');
    }
  }

  Future<void> _refreshCartFromServer() async {
    final token = context.read<AuthProvider>().token;
    if (token == null || _cartCode == null) return;
    try {
      final json = await CartService.getCart(_cartCode!, token);
      final items = (json['items'] as List<dynamic>)
          .map((it) => CartItem.fromJson(it))
          .toList();
      if (!mounted) return;
      setState(() => _cartItems = items);
    } catch (e) {
      debugPrint('Failed to refresh cart: $e');
    }
  }

  void _onCategorySelected(int? categoryId) {
    setState(() => _selectedCategoryId = categoryId);
    _loadProducts();
  }

  Future<void> _addToCart(Product product) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      _showError('Silakan login terlebih dahulu');
      return;
    }

    if (_addingProductIds.contains(product.id)) return;
    setState(() => _addingProductIds.add(product.id));

    try {
      if (_cartCode == null) {
        _cartCode = await CartService.createCart(token);
      }

      await CartService.addItem(_cartCode!, product.sku, 1, token);
      if (!mounted) return;
      await _refreshCartFromServer();
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _addingProductIds.remove(product.id));
      }
    }
  }

  Future<void> _updateItemQty(CartItem item, int newQty) async {
    final token = context.read<AuthProvider>().token;
    if (token == null || _cartCode == null) return;

    setState(() => _updatingItemIds.add(item.id));

    try {
      if (newQty <= 0) {
        await CartService.removeItem(_cartCode!, item.id, token);
      } else {
        await CartService.updateItem(_cartCode!, item.id, newQty, token);
      }
      if (!mounted) return;
      await _refreshCartFromServer();
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _updatingItemIds.remove(item.id));
      }
    }
  }

  Future<void> _removeItem(CartItem item) async {
    await _updateItemQty(item, 0);
  }

  double get _total =>
      _cartItems.fold(0.0, (sum, item) => sum + item.subtotal);

  Future<void> _checkout() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      _showError('Silakan login terlebih dahulu');
      return;
    }

    final cash = double.tryParse(_cashController.text) ?? 0;
    if (cash < _total) {
      _showError('Uang tidak cukup');
      return;
    }

    if (_cartCode == null || _cartItems.isEmpty) {
      _showError('Keranjang kosong');
      return;
    }

    setState(() => _isCheckingOut = true);

    try {
      final resp = await CartService.checkout(_cartCode!, cash, token);
      if (!mounted) return;

      final kembali = cash - _total;
      final invoice = resp['transaction']?['invoice_number']?.toString();

      _showSuccessDialog(
        total: _total,
        cash: cash,
        change: kembali,
        invoice: invoice,
        token: token,
      );
    } catch (e) {
      if (mounted) _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isCheckingOut = false);
      }
    }
  }

  void _showSuccessDialog({
    required double total,
    required double cash,
    required double change,
    String? invoice,
    required String token,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF3E8FF)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFF7C3AED), Color(0xFF2DD4BF)],
                  ),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Transaksi Berhasil!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 24),
              _buildSummaryRow('Total', 'Rp ${_formatPrice(total)}'),
              const SizedBox(height: 8),
              _buildSummaryRow('Bayar', 'Rp ${_formatPrice(cash)}'),
              const Divider(height: 24),
              _buildSummaryRow(
                'Kembalian',
                'Rp ${_formatPrice(change)}',
                isHighlighted: true,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  if (invoice != null)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () async {
                          Navigator.pop(ctx);
                          await _downloadReceipt(invoice, token);
                          _resetAfterCheckout();
                        },
                        icon: const Icon(Icons.receipt_long_rounded, size: 18),
                        label: const Text('Cetak Struk'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF7C3AED),
                          side: const BorderSide(color: Color(0xFF7C3AED)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  if (invoice != null) const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _resetAfterCheckout();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Selesai'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isHighlighted ? 18 : 15,
            fontWeight: isHighlighted ? FontWeight.w700 : FontWeight.w600,
            color: isHighlighted
                ? const Color(0xFF7C3AED)
                : const Color(0xFF1F2937),
          ),
        ),
      ],
    );
  }

  Future<void> _downloadReceipt(String invoice, String token) async {
    try {
      final bytes = await CartService.getReceiptBytes(invoice, token);
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = 'struk-$invoice.pdf';
      html.document.body?.append(anchor);
      anchor.click();
      anchor.remove();
      html.Url.revokeObjectUrl(url);
    } catch (e) {
      if (mounted) _showError('Gagal download receipt: $e');
    }
  }

  void _resetAfterCheckout() async {
    setState(() {
      _cartItems.clear();
      _cashController.clear();
    });
    await _loadProducts();
    await _createCart();
  }

  Future<void> _scanBarcode() async {
    // Show options: Scan with camera or manual input
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Cari Produk',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.qr_code_scanner_rounded,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                title: const Text('Scan Barcode'),
                subtitle: const Text('Gunakan kamera'),
                onTap: () => Navigator.pop(ctx, 'scan'),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2DD4BF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.keyboard_rounded,
                    color: Color(0xFF2DD4BF),
                  ),
                ),
                title: const Text('Input Manual'),
                subtitle: const Text('Ketik barcode/SKU'),
                onTap: () => Navigator.pop(ctx, 'manual'),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == null) return;

    String? code;
    
    if (choice == 'scan') {
      // Scan with camera
      code = await Navigator.push<String?>(
        context,
        MaterialPageRoute(builder: (_) => const ScannerScreen()),
      );
    } else if (choice == 'manual') {
      // Manual input
      final controller = TextEditingController();
      code = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Input Barcode/SKU'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Masukkan kode produk',
              prefixIcon: const Icon(Icons.barcode_reader),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onSubmitted: (value) {
              if (value.isNotEmpty) {
                Navigator.pop(ctx, value);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (controller.text.isNotEmpty) {
                  Navigator.pop(ctx, controller.text);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
              ),
              child: const Text('Cari'),
            ),
          ],
        ),
      );
    }
    
    if (code == null || code.isEmpty) return;

    try {
      final products = await ProductService.getProducts(search: code);
      if (products.isEmpty) {
        if (mounted) _showError('Produk tidak ditemukan');
      } else {
        await _addToCart(products.first);
      }
    } catch (e) {
      if (mounted) _showError('Gagal cari produk: $e');
    }
  }

  void _logout() {
    context.read<AuthProvider>().logout();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  String _formatPrice(double price) {
    final intPrice = price.toInt();
    return intPrice.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]}.',
        );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF8FAFC),
      endDrawer: isWide ? null : _buildCartDrawer(),
      body: SafeArea(
        child: Row(
          children: [
            // Main Content
            Expanded(
              flex: isWide ? 2 : 1,
              child: Column(
                children: [
                  _buildHeader(isWide),
                  const SizedBox(height: 12),
                  CategoryFilter(
                    categories: _categories,
                    selectedCategoryId: _selectedCategoryId,
                    onCategorySelected: _onCategorySelected,
                    isLoading: _isLoadingCategories,
                  ),
                  const SizedBox(height: 12),
                  Expanded(child: _buildProductGrid()),
                ],
              ),
            ),
            // Cart Panel (Wide screens)
            if (isWide) _buildCartPanel(),
          ],
        ),
      ),
      // Cart FAB (Mobile)
      floatingActionButton: isWide
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              backgroundColor: const Color(0xFF7C3AED),
              icon: const Icon(Icons.shopping_cart_rounded),
              label: Text(
                '${_cartItems.length} item',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
    );
  }

  Widget _buildHeader(bool isWide) {
    return AppHeader(
      title: 'Sales Store',
      subtitle: 'Kasir POS',
      actions: [
        _buildIconButton(
          icon: Icons.qr_code_scanner_rounded,
          tooltip: 'Scan Barcode',
          onTap: _scanBarcode,
        ),
      ],
      onLogout: _logout,
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: isDestructive
                  ? Colors.red.shade50
                  : Colors.grey.shade100,
            ),
            child: Icon(
              icon,
              color: isDestructive
                  ? Colors.red.shade600
                  : Colors.grey.shade700,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductGrid() {
    if (_isLoadingProducts) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF7C3AED),
        ),
      );
    }

    if (_products.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'Tidak ada produk untuk "$_searchQuery"'
                  : 'Belum ada produk',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadProducts,
      color: const Color(0xFF7C3AED),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 200,
          childAspectRatio: 0.75,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _products.length,
        itemBuilder: (context, index) {
          final product = _products[index];
          return ProductCard(
            product: product,
            isLoading: _addingProductIds.contains(product.id),
            onAddToCart: () => _addToCart(product),
            onViewDetail: () {
              showDialog(
                context: context,
                builder: (context) => ProductDetailScreen(product: product),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildCartPanel() {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF2DD4BF)],
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.shopping_cart_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Keranjang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_cartItems.length} item',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Items
          Expanded(child: _buildCartItems()),
          // Summary
          CartSummary(
            total: _total,
            itemCount: _cartItems.length,
            cashController: _cashController,
            onCheckout: _checkout,
            isCheckingOut: _isCheckingOut,
          ),
        ],
      ),
    );
  }

  Widget _buildCartDrawer() {
    return Drawer(
      width: 340,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 16,
              left: 16,
              right: 16,
              bottom: 16,
            ),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF2DD4BF)],
              ),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded, color: Colors.white),
                ),
                const Expanded(
                  child: Text(
                    'Keranjang',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${_cartItems.length} item',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(child: _buildCartItems()),
          CartSummary(
            total: _total,
            itemCount: _cartItems.length,
            cashController: _cashController,
            onCheckout: _checkout,
            isCheckingOut: _isCheckingOut,
          ),
        ],
      ),
    );
  }

  Widget _buildCartItems() {
    if (_cartItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 48,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Keranjang kosong',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _cartItems.length,
      itemBuilder: (context, index) {
        final item = _cartItems[index];
        return CartItemTile(
          item: item,
          isUpdating: _updatingItemIds.contains(item.id),
          onIncrement: () => _updateItemQty(item, item.qty + 1),
          onDecrement: () => _updateItemQty(item, item.qty - 1),
          onRemove: () => _removeItem(item),
        );
      },
    );
  }
}
