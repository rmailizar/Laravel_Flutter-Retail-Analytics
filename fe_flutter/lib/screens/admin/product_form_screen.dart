import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/product.dart';
import '../../models/category.dart';
import '../../providers/auth_provider.dart';
import '../../services/product_service.dart';
import '../../services/category_service.dart';

class ProductFormScreen extends StatefulWidget {
  final Product? product;

  const ProductFormScreen({super.key, this.product});

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _barcodeController;
  late TextEditingController _costController;
  late TextEditingController _sellController;
  late TextEditingController _stockController;

  List<Category> _categories = [];
  int? _selectedCategoryId;
  bool _isLoading = false;
  bool _isLoadingCategories = true;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product?.name ?? '');
    _skuController = TextEditingController(text: widget.product?.sku ?? '');
    _barcodeController = TextEditingController(text: widget.product?.barcode ?? '');
    _costController = TextEditingController(
      text: widget.product?.costPrice.toInt().toString() ?? '0',
    );
    _sellController = TextEditingController(
      text: widget.product?.sellPrice.toInt().toString() ?? '0',
    );
    _stockController = TextEditingController(
      text: widget.product?.stock.toString() ?? '0',
    );
    
    // Set selected category if editing
    if (_isEdit && widget.product?.categoryId != null) {
      _selectedCategoryId = widget.product!.categoryId;
    }
    
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await CategoryService.getCategories();
      if (!mounted) return;
      setState(() {
        _categories = categories;
        _isLoadingCategories = false;
        
        // Re-validate selected category after categories loaded
        if (_selectedCategoryId != null) {
          final categoryExists = categories.any((c) => c.id == _selectedCategoryId);
          if (!categoryExists) {
            _selectedCategoryId = null;
          }
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoadingCategories = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _barcodeController.dispose();
    _costController.dispose();
    _sellController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final token = context.read<AuthProvider>().token;
    if (token == null || token.isEmpty) {
      _showError('Anda belum autentikasi. Silakan login.');
      setState(() => _isLoading = false);
      return;
    }

    final data = {
      "name": _nameController.text.trim(),
      "sku": _skuController.text.trim(),
      "barcode": _barcodeController.text.trim(),
      "cost_price": _costController.text,
      "sell_price": _sellController.text,
      "active": 1,
      if (_selectedCategoryId != null) "category_id": _selectedCategoryId,
      if (!_isEdit) "stock": _stockController.text, // Only on create
    };

    try {
      if (_isEdit) {
        await ProductService.updateProduct(widget.product!.id, data, token);
      } else {
        await ProductService.createProduct(data, token);
      }

      if (!mounted) return;
      _showSuccess(_isEdit ? 'Produk berhasil diupdate' : 'Produk berhasil ditambahkan');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showError(e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildForm()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => Navigator.pop(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey.shade100,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isEdit ? 'Edit Produk' : 'Tambah Produk',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
                Text(
                  _isEdit ? 'Perbarui informasi produk' : 'Isi data produk baru',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Product Info Section
          _buildSectionCard(
            title: 'Informasi Produk',
            icon: Icons.info_outline_rounded,
            children: [
              _buildTextField(
                controller: _nameController,
                label: 'Nama Produk',
                hint: 'Masukkan nama produk',
                icon: Icons.shopping_bag_outlined,
                validator: (v) => v == null || v.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _skuController,
                      label: 'SKU',
                      hint: 'Kode SKU',
                      icon: Icons.qr_code_rounded,
                      validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _barcodeController,
                      label: 'Barcode',
                      hint: 'Kode barcode',
                      icon: Icons.barcode_reader,
                      validator: (v) => v == null || v.isEmpty ? 'Wajib' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildCategoryDropdown(),
            ],
          ),
          const SizedBox(height: 16),
          // Pricing Section
          _buildSectionCard(
            title: 'Harga',
            icon: Icons.payments_outlined,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _costController,
                      label: 'Harga Modal',
                      hint: '0',
                      icon: Icons.money_outlined,
                      keyboardType: TextInputType.number,
                      prefix: 'Rp',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _sellController,
                      label: 'Harga Jual',
                      hint: '0',
                      icon: Icons.sell_outlined,
                      keyboardType: TextInputType.number,
                      prefix: 'Rp',
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Wajib';
                        final price = double.tryParse(v);
                        if (price == null || price < 0) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stock Section - Only visible when creating new product
          if (!_isEdit) ...[
            _buildSectionCard(
              title: 'Stok Awal',
              icon: Icons.inventory_2_outlined,
              children: [
                _buildTextField(
                  controller: _stockController,
                  label: 'Jumlah Stok',
                  hint: '0',
                  icon: Icons.inventory_outlined,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Wajib diisi';
                    final stock = int.tryParse(v);
                    if (stock == null || stock < 0) return 'Harus angka >= 0';
                    return null;
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  'Catatan: Stok produk yang sudah ada dikelola melalui fitur "Atur Stok"',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
          
          const SizedBox(height: 8),
          // Submit Button
          _buildSubmitButton(),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7C3AED), Color(0xFF2DD4BF)],
                    ),
                  ),
                  child: Icon(icon, color: Colors.white, size: 16),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? prefix,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 14),
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixText: prefix != null ? '$prefix ' : null,
        prefixStyle: TextStyle(
          color: Colors.grey.shade700,
          fontWeight: FontWeight.w600,
        ),
        prefixIcon: Icon(icon, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red.shade400),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int?>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Kategori',
        prefixIcon: Icon(Icons.category_outlined, color: Colors.grey.shade400, size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF7C3AED), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      hint: _isLoadingCategories
          ? const Text('Memuat kategori...')
          : const Text('Pilih kategori (opsional)'),
      items: _categories.map((cat) {
        return DropdownMenuItem<int?>(
          value: cat.id,
          child: Text(cat.name),
        );
      }).toList(),
      onChanged: (value) {
        setState(() => _selectedCategoryId = value);
      },
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: const LinearGradient(
              colors: [Color(0xFF7C3AED), Color(0xFF2DD4BF)],
            ),
          ),
          child: Container(
            alignment: Alignment.center,
            child: _isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _isEdit ? Icons.save_rounded : Icons.add_rounded,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _isEdit ? 'SIMPAN PERUBAHAN' : 'TAMBAH PRODUK',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
