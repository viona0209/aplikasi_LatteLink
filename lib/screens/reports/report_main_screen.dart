import 'package:flutter/material.dart';
import 'package:aplikasi_lattelink/screens/reports/sales_report_screen.dart';
import 'package:aplikasi_lattelink/screens/reports/transactions_report_screen.dart';
import 'package:aplikasi_lattelink/screens/reports/profit_loss_screen.dart';
import '../../widgets/sidebar_menu.dart';

enum ReportTab { sales, transactions, profitLoss }

class ReportMainScreen extends StatefulWidget {
  final ReportTab initialTab;

  const ReportMainScreen({super.key, required this.initialTab});

  @override
  State<ReportMainScreen> createState() => _ReportMainScreenState();
}

class _ReportMainScreenState extends State<ReportMainScreen> {
  late int selectedIndex;

  final Color primary = const Color(0xFF6E200D);

  final screens = const [
  SalesReportScreen(),
  TransactionsReportScreen(),   // tanpa parameter!
  ProfitLossScreen(),
];


  @override
  void initState() {
    super.initState();
    selectedIndex = widget.initialTab.index;
  }

  // ==========================
  // OPEN SIDEBAR (SAMA PERSIS)
  // ==========================
  void _openSidebar(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: size.width < 600 ? size.width * 0.8 : 350,
              height: size.height * 0.9,
              margin: const EdgeInsets.only(top: 40, bottom: 60),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                child: Material(
                  color: Colors.white,
                  child: SidebarMenu(selected: "report"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // CUSTOM TAB BUTTON
  Widget buildTabButton(String label, int index) {
    bool isSelected = selectedIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => selectedIndex = index),
        child: Container(
          height: 45,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? primary : const Color(0xFFEDDEDA),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: primary),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isSelected ? Colors.white : primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isSmall = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      backgroundColor: Colors.white,

      // ==========================
      // APPBAR SAMA SEPERTI StockPage
      // ==========================
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 25, left: 25),
            child: AppBar(
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              elevation: 0,
              automaticallyImplyLeading: false,
              titleSpacing: 0,

              title: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.menu,
                        color: primary, size: isSmall ? 24 : 28),
                    onPressed: () => _openSidebar(context),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    "Report",
                    style: TextStyle(
                      fontSize: isSmall ? 18 : 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),

              // actions: [
              //   Container(
              //     margin: const EdgeInsets.only(right: 20),
              //     decoration: BoxDecoration(
              //       color: primary,
              //       borderRadius: BorderRadius.circular(10),
              //     ),
              //     child: IconButton(
              //       icon: const Icon(Icons.print, color: Colors.white),
              //       onPressed: () {
              //         // TODO: PRINT LOGIC DI SINI
              //       },
              //     ),
              //   )
              // ],
            ),
          ),
        ),
      ),

      // ==========================
      // BODY
      // ==========================
      body: Column(
        children: [
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                buildTabButton("Sales Reports", 0),
                const SizedBox(width: 10),
                buildTabButton("Reports", 1),
                const SizedBox(width: 10),
                buildTabButton("Loss Profit", 2),
              ],
            ),
          ),

          const SizedBox(height: 20),

          Expanded(child: screens[selectedIndex]),
        ],
      ),
    );
  }
}
