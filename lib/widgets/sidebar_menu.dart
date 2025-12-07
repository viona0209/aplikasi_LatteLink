import 'package:aplikasi_lattelink/screens/reports/report_main_screen.dart';
import 'package:aplikasi_lattelink/screens/user/Login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../screens/chasier/chasier.dart';
import '../screens/customer/customer.dart';
import '../screens/dashboard/dashboard.dart' show DashboardScreen;
import '../screens/products/product.dart' show ProductPage;
import '../screens/stock/stock.dart';

class SidebarMenu extends StatelessWidget {
  final String selected;

  const SidebarMenu({super.key, required this.selected});

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            width: 320,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Confirm Logout",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Are you sure you want to Logout?",
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE8C7B8),
                        foregroundColor: Colors.black,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B3A2E),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () async {
                        await Supabase.instance.client.auth.signOut();
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                          (route) => false,
                        );
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>> _getProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return {};
    final res = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('user_id', user.id)
        .single();

    return res;
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(25),
          bottomRight: Radius.circular(25),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder(
              future: _getProfile(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }

                final profile = snapshot.data!;
                final name = profile['name'] ?? "User";
                final role = profile['role'] ?? "Unknown";
                final email =
                    Supabase.instance.client.auth.currentUser?.email ?? "-";

                return Row(
                  children: [
                    Container(
                      width: 98,
                      height: 99,
                      decoration: const BoxDecoration(
                        color: Color(0xFF6E200D),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : "U",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 64,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(role, style: const TextStyle(fontSize: 22)),
                        Text(
                          email,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 30),
            _menuItem(
              context,
              icon: Icons.dashboard_outlined,
              label: "Dashboard",
              isActive: selected == "dashboard",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardScreen()),
                );
              },
            ),
            _menuItem(
              context,
              icon: Icons.inventory_2_outlined,
              label: "Product",
              isActive: selected == "product",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProductPage()),
                );
              },
            ),
            _menuItem(
              context,
              icon: Icons.person_outline,
              label: "Chasier",
              isActive: selected == "chasier",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CashierPage()),
                );
              },
            ),
            _menuItem(
              context,
              icon: Icons.group_outlined,
              label: "Customer",
              isActive: selected == "customer",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const CustomerPage()),
                );
              },
            ),
            _menuItem(
              context,
              icon: Icons.store_outlined,
              label: "Stock",
              isActive: selected == "stock",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const StockPage()),
                );
              },
            ),
            _menuItem(
              context,
              icon: Icons.bar_chart_outlined,
              label: "Report",
              isActive: selected == "report",
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const ReportMainScreen(initialTab: ReportTab.sales),
                  ),
                );
              },
            ),
            _menuItem(
              context,
              icon: Icons.logout,
              label: "Logout",
              isActive: false,
              onTap: () {
                _showLogoutDialog(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _menuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required Function() onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          decoration: BoxDecoration(
            color: isActive ? const Color(0xFF6E200D) : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            children: [
              Icon(icon, color: isActive ? Colors.white : Colors.black),
              const SizedBox(width: 18),
              Text(
                label,
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.black,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
