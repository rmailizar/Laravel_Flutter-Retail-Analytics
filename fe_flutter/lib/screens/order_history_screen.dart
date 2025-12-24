import 'package:flutter/material.dart';
import '../models/order.dart';
import '../services/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  late Future<List<Order>> orders;

  @override
  void initState() {
    super.initState();
    orders = OrderService.getOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Riwayat Transaksi")),
      body: FutureBuilder<List<Order>>(
        future: orders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Belum ada transaksi"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, i) {
              final o = snapshot.data![i];
              return Card(
                child: ListTile(
                  leading: Icon(Icons.receipt_long),
                  title: Text("Order #${o.id}"),
                  subtitle: Text(o.createdAt),
                  trailing: Text(
                    "Rp ${o.total}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
