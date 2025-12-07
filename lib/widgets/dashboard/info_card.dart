import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:aplikasi_lattelink/screens/dashboard/dashboard_stock.dart';
import 'package:aplikasi_lattelink/screens/dashboard/dashboard_customer.dart';
import 'package:aplikasi_lattelink/screens/dashboard/dashboard_transaction.dart';

class InfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final int number;
  final bool isActive;
  final VoidCallback? onTap;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.number,
    this.onTap,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bool isSmall = size.width < 360;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFEFD7C8) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isActive ? const Color(0xFF6E200D) : const Color(0x246E200D),
            width: isActive ? 4.5 : 4.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: const Color(0xFFB05B3B),
                  size: isSmall ? 22 : 28,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: isSmall ? 12 : 14,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF474747),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                number.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: isSmall ? 28 : 36,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCards extends StatefulWidget {
  final String activeCard;

  const DashboardCards({super.key, required this.activeCard});

  @override
  State<DashboardCards> createState() => _DashboardCardsState();
}

class _DashboardCardsState extends State<DashboardCards> {
  final supabase = Supabase.instance.client;

  int productCount = 0;
  int customerCount = 0;
  int transactionCount = 0;

  @override
  void initState() {
    super.initState();
    _loadCounts();
    _setupRealtime();
  }

  Future<void> _loadCounts() async {
    final products = await supabase.from('products').select();
    final customers = await supabase.from('customers').select();
    final transactions = await supabase.from('transactions').select();

    if (!mounted) return;

    setState(() {
      productCount = products.length;
      customerCount = customers.length;
      transactionCount = transactions.length;
    });
  }

  void _setupRealtime() {
    supabase
        .channel('products_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) => _loadCounts(),
        )
        .subscribe();
    supabase
        .channel('customers_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'customers',
          callback: (payload) => _loadCounts(),
        )
        .subscribe();
    supabase
        .channel('transactions_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'transactions',
          callback: (payload) => _loadCounts(),
        )
        .subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: InfoCard(
                icon: Icons.shopping_cart_sharp,
                title: "Stock Products",
                number: productCount,
                isActive: widget.activeCard == "stock",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardStock()),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InfoCard(
                icon: Icons.person,
                title: "Customer",
                number: customerCount,
                isActive: widget.activeCard == "customer",
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const DashboardCustomer()),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const DashboardTransaction()),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: widget.activeCard == "transaction"
                  ? const Color(0xFFEFD7C8)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.activeCard == "transaction"
                    ? const Color(0xFF6E200D)
                    : const Color(0x246E200D),
                width: widget.activeCard == "transaction" ? 4.5 : 4.0,
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.history, size: 90, color: Color(0xFFB05B3B)),
                const SizedBox(width: 16),
                Text(
                  "Transaction ($transactionCount)",
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
