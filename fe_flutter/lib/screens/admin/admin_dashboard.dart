import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../services/dashboard_service.dart';
import 'product_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  late Future<Map<String, dynamic>> summary;

  @override
  void initState() {
    super.initState();
    summary = DashboardService.getSummary();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Dashboard Admin")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: summary,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!;
          final dailySales = data['daily_sales'] as List;

          return ListView(
            padding: EdgeInsets.all(16),
            children: [
              // KPI
              Row(
                children: [
                  _kpiCard("Total Sales", "Rp ${data['total_sales']}"),
                  _kpiCard("Total Orders", data['total_orders'].toString()),
                ],
              ),

              SizedBox(height: 30),

              Text(
                "Penjualan 7 Hari Terakhir",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),

              SizedBox(height: 10),

              SizedBox(
                height: 250,
                child: LineChart(
                  LineChartData(
                    titlesData: FlTitlesData(show: true),
                    borderData: FlBorderData(show: true),
                    lineBarsData: [
                      LineChartBarData(
                        spots: dailySales.asMap().entries.map((e) {
                          return FlSpot(
                            e.key.toDouble(),
                            (e.value['total'] as num).toDouble(),
                          );
                        }).toList(),
                        isCurved: true,
                        barWidth: 3,
                        dotData: FlDotData(show: true),
                      )
                    ],
                  ),
                ),
              ),

              SizedBox(height: 30),

              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => ProductScreen()),
                  );
                },
                child: Text("Kelola Produk"),
              )
            ],
          );
        },
      ),
    );
  }

  Expanded _kpiCard(String title, String value) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            children: [
              Text(title),
              SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
