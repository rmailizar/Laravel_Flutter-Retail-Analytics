import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../login_screen.dart';
import 'scanner_screen.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../services/cart_service.dart';

class CartItem {
  final int id; // server cart item id
  final Product product;
  int qty;

  CartItem(this.id, this.product, this.qty);
}

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  late Future<List<Product>> productsFuture;
  String? cartCode;

  final List<CartItem> cart = [];
  final bayarCtrl = TextEditingController();
  final Set<int> _addingProductIds = {};

  @override
  void initState() {
    super.initState();
    productsFuture = ProductService.getProducts();
    // create cart after first frame so context is available for provider
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final token = context.read<AuthProvider>().token;
      if (token == null) return;
      try {
        final code = await CartService.createCart(token);
        if (!mounted) return;
        setState(() => cartCode = code);
      } catch (e) {
        // ignore for now, could show snackbar
      }
    });
  }

  void addToCart(Product p) async {
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    // prevent duplicate rapid adds for the same product
    if (_addingProductIds.contains(p.id)) return;
    _addingProductIds.add(p.id);

    try {
      if (cartCode == null) {
        cartCode = await CartService.createCart(token);
      }

      await CartService.addItem(cartCode!, p.sku, 1, token);

      if (!mounted) return;
      // refresh server cart to reflect current items
      await _refreshCartFromServer(token);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      _addingProductIds.remove(p.id);
    }
  }

  Future<void> _refreshCartFromServer(String token) async {
    if (cartCode == null) return;
    final json = await CartService.getCart(cartCode!, token);
    final items = (json['items'] as List<dynamic>).map((it) {
      final prod = Product.fromJson(it['product']);
      final qty = it['qty'] as int;
      final itemId = it['id'] as int;
      return CartItem(itemId, prod, qty);
    }).toList();
    if (!mounted) return;
    setState(() {
      cart.clear();
      cart.addAll(items);
    });
  }

  double get total =>
      cart.fold(0.0, (sum, i) => sum + i.qty * i.product.sellPrice);

  void bayar() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan login terlebih dahulu')),
      );
      return;
    }

    final cash = double.tryParse(bayarCtrl.text) ?? 0;
    if (cash < total) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uang kurang")),
      );
      return;
    }

    if (cartCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cart belum dibuat / kosong')),
      );
      return;
    }

    try {
      final resp = await CartService.checkout(cartCode!, cash, token);

      if (!mounted) return;
      final kembali = cash - total;

      final invoice = resp['transaction']?['invoice_number']?.toString();

      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Transaksi Berhasil"),
          content: Text(
            "Total : Rp ${total.toStringAsFixed(0)}\n"
            "Bayar : Rp ${cash.toStringAsFixed(0)}\n"
            "Kembali : Rp ${kembali.toStringAsFixed(0)}",
          ),
          actions: [
            if (invoice != null)
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);

                  try {
                    // 🔽 DOWNLOAD + PREVIEW PDF (ANDROID)
                    await CartService.downloadReceiptAndroid(
                      invoice: invoice,
                      token: token,
                    );
                  } catch (e) {
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Gagal cetak struk: $e')),
                      );
                    }
                    return; // hentikan flow kalau gagal cetak
                  }

                  // =========================
                  // RESET CART & UI (AMAN)
                  // =========================
                  if (!mounted) return;

                  setState(() {
                    cart.clear();
                    bayarCtrl.clear();
                  });

                  // refresh product list (stok terbaru)
                  setState(() {
                    productsFuture = ProductService.getProducts();
                  });

                  // buat cart baru untuk transaksi berikutnya
                  try {
                    final token = context.read<AuthProvider>().token;
                    if (token != null) {
                      final newCode = await CartService.createCart(token);
                      if (!mounted) return;
                      setState(() => cartCode = newCode);
                    }
                  } catch (_) {
                    setState(() => cartCode = null);
                  }
                },
                child: const Text('Cetak Struk'),
              ),
              
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                setState(() {
                  cart.clear();
                  bayarCtrl.clear();
                });
                // refresh product list to reflect updated stocks
                setState(() {
                  productsFuture = ProductService.getProducts();
                });

                // create a fresh cart for subsequent purchases
                try {
                  final token = context.read<AuthProvider>().token;
                  if (token != null) {
                    final newCode = await CartService.createCart(token);
                    if (!mounted) return;
                    setState(() => cartCode = newCode);
                  }
                } catch (_) {
                  setState(() => cartCode = null);
                }
              },
              child: const Text("OK"),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("POS Kasir"),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
        actions: [
          IconButton(
            tooltip: 'Scan Barcode',
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () async {
              // open scanner and await result
              final code = await Navigator.push<String?>(
                context,
                MaterialPageRoute(builder: (_) => const ScannerScreen()),
              );
              if (code == null || code.isEmpty) return;

              // try to find product by SKU from server
              try {
                final products = await ProductService.getProducts();
                final match = products.where((p) => p.sku == code).toList();
                if (match.isEmpty) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Produk tidak ditemukan')),
                    );
                  }
                } else {
                  // add first matched product
                  addToCart(match.first);
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Gagal cari produk: $e')),
                  );
                }
              }
            },
          ),
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthProvider>().logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // ===== PRODUK =====
          Expanded(
            flex: 2,
            child: FutureBuilder<List<Product>>(
              future: productsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                final products = snapshot.data ?? [];
                if (products.isEmpty) {
                  return const Center(child: Text('Produk kosong'));
                }
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (_, i) {
                    final p = products[i];
                    return Card(
                      child: ListTile(
                        title: Text(p.name),
                        subtitle:
                            Text("Rp ${p.sellPrice.toInt()} | Stok ${p.stock}"),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_shopping_cart),
                          onPressed: () => addToCart(p),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // ===== KERANJANG =====
          Expanded(
            flex: 1,
            child: Container(
              color: Colors.grey[100],
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(8),
                    child: Text(
                      "Keranjang",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      itemCount: cart.length,
                      itemBuilder: (_, i) {
                        final c = cart[i];
                        return ListTile(
                          title: Text(c.product.name),
                          subtitle: Text("${c.qty} x ${c.product.sellPrice}"),
                          trailing: IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: () async {
                              final token = context.read<AuthProvider>().token;
                              if (token == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Silakan login terlebih dahulu')),
                                );
                                return;
                              }

                              // decrease qty locally and on server
                              final newQty = c.qty - 1;
                              try {
                                if (newQty <= 0) {
                                  // remove on server
                                  if (cartCode != null) {
                                    await CartService.removeItem(
                                        cartCode!, c.id, token);
                                  }
                                  if (!mounted) return;
                                  setState(() {
                                    cart.removeAt(i);
                                  });
                                } else {
                                  // update on server
                                  if (cartCode != null) {
                                    await CartService.updateItem(
                                        cartCode!, c.id, newQty, token);
                                  }
                                  if (!mounted) return;
                                  setState(() {
                                    cart[i].qty = newQty;
                                  });
                                }
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Text(
                          "TOTAL : Rp ${total.toStringAsFixed(0)}",
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: bayarCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Bayar",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: bayar,
                            child: const Text("BAYAR"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
