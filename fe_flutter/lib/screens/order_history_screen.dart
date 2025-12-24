import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../providers/auth_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<Order> _orders = [];
  bool _isLoading = true;
  String? _error;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_hasLoaded) {
        _hasLoaded = true;
        _loadOrders();
      }
    });
  }

  Future<void> _loadOrders() async {
    if (!mounted) return;
    
    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;
    
    print('🔑 [_loadOrders] Using token: ${token?.substring(0, 20)}...');
    print('🔑 [_loadOrders] IsLoading before: $_isLoading');
    
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await OrderService.getOrders(token: token);
      print('✅ [_loadOrders] Got ${orders.length} orders');
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
        print('✅ [_loadOrders] State updated: ${_orders.length} orders, isLoading: $_isLoading');
      }
    } catch (e) {
      print('❌ Error loading orders: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    print('🎨 [build] _isLoading: $_isLoading, _orders.length: ${_orders.length}, _error: $_error');
    
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Transaksi"),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadOrders,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _orders.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.receipt_long, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text("Belum ada transaksi"),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadOrders,
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: _loadOrders,
                      child: ListView.builder(
                        itemCount: _orders.length,
                        itemBuilder: (context, i) {
                          final o = _orders[i];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              leading: const Icon(Icons.receipt_long),
                              title: Text(o.invoiceNumber),
                              subtitle: Text(o.createdAt),
                              trailing: Text(
                                "Rp ${o.totalAmount.toInt()}",
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
