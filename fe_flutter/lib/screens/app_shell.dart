import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'admin/admin_dashboard.dart';
import 'kasir/sales_screen.dart';
import 'order_history_screen.dart';
import 'login_screen.dart';

class AppShell extends StatefulWidget {
  final int initialIndex;

  const AppShell({super.key, this.initialIndex = 0});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late int _selectedIndex;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onNavTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final role = context.read<AuthProvider>().role ?? '';
    final isAdmin = role == 'admin';

    // Filter nav items based on role
    final navItems = isAdmin
        ? [
            _NavItem(
              icon: Icons.dashboard_rounded,
              label: 'Dashboard',
              screen: const AdminDashboard(),
            ),
            _NavItem(
              icon: Icons.history_rounded,
              label: 'Riwayat',
              screen: const OrderHistoryScreen(),
            ),
          ]
        : [
            _NavItem(
              icon: Icons.shopping_cart_rounded,
              label: 'Penjualan',
              screen: const SalesScreen(),
            ),
            _NavItem(
              icon: Icons.history_rounded,
              label: 'Riwayat',
              screen: const OrderHistoryScreen(),
            ),
          ];

    return WillPopScope(
      onWillPop: () async {
        // Prevent back to login
        return false;
      },
      child: Scaffold(
        body: navItems[_selectedIndex].screen,
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onNavTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            elevation: 0,
            selectedItemColor: const Color(0xFF7C3AED),
            unselectedItemColor: Colors.grey.shade400,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
            items: navItems
                .map(
                  (item) => BottomNavigationBarItem(
                    icon: Icon(item.icon, size: 24),
                    activeIcon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFF2DD4BF)],
                        ),
                      ),
                      child: Icon(
                        item.icon,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    label: item.label,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final Widget screen;

  _NavItem({
    required this.icon,
    required this.label,
    required this.screen,
  });
}
