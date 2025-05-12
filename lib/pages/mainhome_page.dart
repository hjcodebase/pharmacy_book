import 'package:flutter/material.dart';
import 'package:med_x/pages/about_me.dart';
import 'package:med_x/pages/scanbarcode.dart';
import 'package:med_x/pages/stock_entry.dart';
import 'package:med_x/pages/stocks_lists.dart';
import 'package:med_x/pages/udhar_page.dart';

class MainHomePage extends StatelessWidget {
  const MainHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pharmacy Dashboard'),
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildDashboardOption(
              context,
              icon: Icons.receipt,
              title: 'Generate Bill',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => BarcodeScannerPage()));
              }, // Leave for your navigation
            ),
            _buildDashboardOption(
              context,
              icon: Icons.add_box,
              title: 'Stock Entry',
              onTap: () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (_) => StockEntry()));
              }, // Leave for your navigation
            ),
            _buildDashboardOption(
              context,
              icon: Icons.inventory,
              title: 'Stocks Data',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const StockListScreen()));
              }, // Leave for your navigation
            ),
            _buildDashboardOption(
              context,
              icon: Icons.account_balance_wallet,
              title: 'Udhar Khata',
              onTap: () {}, // Leave for your navigation
            ),
            _buildDashboardOption(
              context,
              icon: Icons.bar_chart,
              title: 'Daily Sales',
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const UdharKhataPage()));
              }, // Leave for your navigation
            ),
            _buildDashboardOption(
              context,
              icon: Icons.person,
              title: 'Profile Info',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileInfoPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardOption(BuildContext context,
      {required IconData icon,
      required String title,
      required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: Colors.white,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: const Color(0xFF2196F3)),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
