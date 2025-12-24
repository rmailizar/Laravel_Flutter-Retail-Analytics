import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/dashboard_service.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_header.dart';
import '../login_screen.dart';
import 'product_screen.dart';
import 'category_screen.dart';
import 'transaction_history_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<Map<String, dynamic>> summary;
  List<Map<String, dynamic>> dailySales = [];
  bool _isLoadingChart = true;

  @override
  void initState() {
    super.initState();
    // Initialize; real API call occurs in didChangeDependencies to access AuthProvider token
    summary = Future.value({});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final token = context.read<AuthProvider>().token;
    print('🏠 [AdminDashboard] Token: ${token?.substring(0, 20)}...');
    summary = DashboardService.getSummary(token: token);
    _loadSalesChart(token);
  }

  Future<void> _loadSalesChart(String? token) async {
    try {
      final chartData = await DashboardService.getSalesChart(token: token);
      print('📈 [AdminDashboard] Chart data received: $chartData');
      if (mounted) {
        setState(() {
          dailySales = chartData.map((e) => e as Map<String, dynamic>).toList();
          _isLoadingChart = false;
        });
        print('📈 [AdminDashboard] Daily sales updated: $dailySales');
      }
    } catch (e) {
      print('❌ [AdminDashboard] Error loading chart: $e');
      if (mounted) {
        setState(() {
          _isLoadingChart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: FutureBuilder<Map<String, dynamic>>(
        future: summary,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Column(
              children: [
                AppHeader(
                  title: 'Dashboard Admin',
                  subtitle: 'Kelola toko Anda',
                  onLogout: () {
                    context.read<AuthProvider>().logout();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  },
                ),
                const Expanded(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ),
              ],
            );
          }

          final data = snapshot.data!;
          print('🎨 [AdminDashboard] Data received: $data');
          print('🎨 [AdminDashboard] total_sales: ${data['total_sales']}');
          print('🎨 [AdminDashboard] total_transactions: ${data['total_transactions']}');
          print('🎨 [AdminDashboard] today_sales: ${data['today_sales']}');
          print('🎨 [AdminDashboard] dailySales list: $dailySales');
          print('🎨 [AdminDashboard] dailySales length: ${dailySales.length}');

          return Column(
            children: [
              AppHeader(
                title: 'Dashboard Admin',
                subtitle: 'Kelola toko Anda',
                onLogout: () {
                  context.read<AuthProvider>().logout();
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                },
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // KPI Cards
                    Row(
                      children: [
                        Expanded(
                          child: _buildKpiCard(
                            "Total Penjualan",
                            "Rp ${_formatPrice(data['total_sales'])}",
                            Icons.payments_rounded,
                            const Color(0xFF7C3AED),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildKpiCard(
                            "Total Transaksi",
                            "${data['total_transactions'] ?? 0}",
                            Icons.receipt_long_rounded,
                            const Color(0xFF2DD4BF),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Chart Section
                    Container(
                      padding: const EdgeInsets.all(16),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Penjualan 7 Hari Terakhir",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 220,
                            child: _isLoadingChart
                                ? const Center(child: CircularProgressIndicator())
                                : dailySales.isEmpty
                                    ? Center(
                                        child: Text(
                                          'Belum ada data penjualan',
                                          style: TextStyle(color: Colors.grey.shade600),
                                        ),
                                      )
                                    : LineChart(
                              LineChartData(
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: false,
                                  getDrawingHorizontalLine: (value) {
                                    return FlLine(
                                      color: Colors.grey.shade200,
                                      strokeWidth: 1,
                                    );
                                  },
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 42,
                                      getTitlesWidget: (value, meta) {
                                        return Text(
                                          '${(value / 1000).toStringAsFixed(0)}k',
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey.shade600,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        if (value.toInt() >= dailySales.length) return const SizedBox();
                                        final date = dailySales[value.toInt()]['date'] ?? '';
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            date.toString().split('-').last,
                                            style: TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border(
                                    left: BorderSide(color: Colors.grey.shade300),
                                    bottom: BorderSide(color: Colors.grey.shade300),
                                  ),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: dailySales.asMap().entries.map((e) {
                                      final total = e.value['total'];
                                      final totalValue = (total is String) 
                                          ? double.tryParse(total) ?? 0.0
                                          : (total is num) 
                                              ? total.toDouble() 
                                              : 0.0;
                                      return FlSpot(
                                        e.key.toDouble(),
                                        totalValue,
                                      );
                                    }).toList(),
                                    isCurved: true,
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF7C3AED), Color(0xFF2DD4BF)],
                                    ),
                                    barWidth: 3,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(
                                      show: true,
                                      getDotPainter: (spot, percent, barData, index) {
                                        return FlDotCirclePainter(
                                          radius: 4,
                                          color: Colors.white,
                                          strokeWidth: 2,
                                          strokeColor: const Color(0xFF7C3AED),
                                        );
                                      },
                                    ),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(0xFF7C3AED).withOpacity(0.2),
                                          const Color(0xFF2DD4BF).withOpacity(0.05),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Quick Actions
                    const Text(
                      "Aksi Cepat",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      "Kelola Produk",
                      Icons.inventory_2_rounded,
                      const Color(0xFF7C3AED),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ProductScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      "Kelola Kategori",
                      Icons.category_rounded,
                      const Color(0xFF2DD4BF),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CategoryScreen()),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildActionButton(
                      "Riwayat Transaksi",
                      Icons.history_rounded,
                      const Color(0xFFEC4899),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const TransactionHistoryScreen()),
                      ),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade200),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatPrice(dynamic price) {
    print('💰 [_formatPrice] Input: $price (type: ${price.runtimeType})');
    
    if (price == null) {
      print('💰 [_formatPrice] Price is null, returning 0');
      return '0';
    }
    
    // Handle string values from backend
    if (price is String) {
      final parsed = double.tryParse(price);
      print('💰 [_formatPrice] Parsed string "$price" to $parsed');
      if (parsed == null) return '0';
      price = parsed;
    }
    
    final intPrice = (price is int) ? price : (price is double) ? price.toInt() : int.tryParse(price.toString()) ?? 0;
    print('💰 [_formatPrice] Final intPrice: $intPrice');
    
    final formatted = intPrice.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    );
    print('💰 [_formatPrice] Formatted: $formatted');
    return formatted;
  }
}
