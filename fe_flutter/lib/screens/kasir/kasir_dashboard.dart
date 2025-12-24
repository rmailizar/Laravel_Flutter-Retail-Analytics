import 'package:flutter/material.dart';
import 'pos_screen.dart';

class KasirDashboard extends StatelessWidget {
  const KasirDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kasir"),
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.maybePop(context),
              )
            : null,
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.point_of_sale),
            title: const Text("Transaksi / Kasir"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => PosScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history),
            title: const Text("Riwayat Transaksi"),
            onTap: () {
              Navigator.push(
  context,
  MaterialPageRoute(builder: (_) => const PosScreen()),
);

            },
          ),
        ],
      ),
    );
  }
}
