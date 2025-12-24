import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config/api.dart';
import '../providers/auth_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _summary;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;

    final authProvider = context.read<AuthProvider>();
    final token = authProvider.token;

    print('📊 [Dashboard] Loading dashboard data...');
    print('📊 [Dashboard] Token: ${token?.substring(0, 20)}...');

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final url = '${Api.baseUrl}/dashboard/summary';
      print('📊 [Dashboard] Fetching from: $url');
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          ...Api.headers,
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );

      print('📊 [Dashboard] Response status: ${response.statusCode}');
      print('📊 [Dashboard] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ [Dashboard] Data loaded: $data');
        if (mounted) {
          setState(() {
            _summary = data;
            _isLoading = false;
          });
          print('✅ [Dashboard] State updated');
        }
      } else {
        throw Exception('Gagal memuat data dashboard: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ [Dashboard] Error: $e');
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
    final authProvider = context.watch<AuthProvider>();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard ${authProvider.role == 'admin' ? 'Admin' : 'Kasir'}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
          ),
        ],
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
                        onPressed: _loadDashboard,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadDashboard,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Card
                        Card(
                          color: Colors.purple.shade700,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.store,
                                    color: Colors.white,
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        authProvider.role == 'admin' 
                                            ? 'Dashboard Admin' 
                                            : 'Dashboard Kasir',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      const Text(
                                        'Kelola toko Anda',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        
                        // Statistics Row
                        Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                'Total Penjualan',
                                'Rp ${_formatNumber(_summary?['total_sales'])}',
                                Icons.attach_money,
                                Colors.purple,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                'Total Transaksi',
                                '${_summary?['total_transactions'] ?? 0}',
                                Icons.receipt_long,
                                Colors.teal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        
                        _buildStatCard(
                          'Penjualan Hari Ini',
                          'Rp ${_formatNumber(_summary?['today_sales'])}',
                          Icons.today,
                          Colors.orange,
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color, {
    bool fullWidth = false,
  }) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.shade400, color.shade700],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white, size: 32),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0';
    if (value is String) {
      value = double.tryParse(value) ?? 0;
    }
    if (value is double || value is int) {
      return value.toInt().toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]}.',
          );
    }
    return '0';
  }
}
