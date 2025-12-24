import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  late Future<List<Product>> products;
  final Map<Product, int> cart = {};

  @override
  void initState() {
    super.initState();
    products = ProductService.getProducts();
  }

  void addToCart(Product p) {
    setState(() {
      cart[p] = (cart[p] ?? 0) + 1;
    });
  }

  void removeFromCart(Product p) {
    setState(() {
      if (cart[p]! > 1) {
        cart[p] = cart[p]! - 1;
      } else {
        cart.remove(p);
      }
    });
  }

  double get total {
    double sum = 0;
    cart.forEach((p, qty) {
      sum += p.sellPrice * qty;
    });
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("POS Kasir")),
      body: Row(
        children: [
          /// ================== PRODUK ==================
          Expanded(
            flex: 3,
            child: FutureBuilder<List<Product>>(
              future: products,
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator());
                }

                if (!snapshot.hasData ||
                    snapshot.data!.isEmpty) {
                  return const Center(
                      child: Text("Produk kosong"));
                }

                return GridView.builder(
                  padding: const EdgeInsets.all(12),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.4,
                  ),
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, i) {
                    final p = snapshot.data![i];
                    return Card(
                      child: InkWell(
                        onTap: () => addToCart(p),
                        child: Column(
                          mainAxisAlignment:
                              MainAxisAlignment.center,
                          children: [
                            Text(p.name,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                                "Rp ${p.sellPrice.toInt()}"),
                            Text("Stok: ${p.stock}"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          /// ================== CART ==================
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.grey.shade100,
              child: Column(
                children: [
                  const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text("Keranjang",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                  ),
                  Expanded(
                    child: ListView(
                      children: cart.entries.map((e) {
                        final p = e.key;
                        final qty = e.value;
                        return ListTile(
                          title: Text(p.name),
                          subtitle: Text(
                              "Rp ${p.sellPrice.toInt()} x $qty"),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: () =>
                                    removeFromCart(p),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () =>
                                    addToCart(p),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                        border:
                            Border(top: BorderSide())),
                    child: Column(
                      children: [
                        Text("TOTAL",
                            style: TextStyle(
                                color: Colors.grey.shade700)),
                        Text(
                          "Rp ${total.toInt()}",
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              minimumSize:
                                  const Size.fromHeight(45)),
                          onPressed: cart.isEmpty
                              ? null
                              : () {
                                  showDialog(
                                    context: context,
                                    builder: (_) =>
                                        AlertDialog(
                                      title: const Text(
                                          "Transaksi"),
                                      content: const Text(
                                          "Transaksi berhasil (dummy)"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            cart.clear();
                                            setState(() {});
                                            Navigator.pop(
                                                context);
                                          },
                                          child:
                                              const Text("OK"),
                                        )
                                      ],
                                    ),
                                  );
                                },
                          child:
                              const Text("BAYAR"),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
