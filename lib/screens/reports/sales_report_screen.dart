import 'package:flutter/material.dart';
import 'package:aplikasi_lattelink/widgets/reports/common_widget.dart';
import 'package:aplikasi_lattelink/widgets/reports/report_tab_view.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final topSellingData = [
      {"name": "Espresso", "price": "25.000", "units": 10},
      {"name": "Cappucino", "price": "20.000", "units": 9},
      {"name": "Red velvet", "price": "15.000", "units": 8},
      {"name": "Matcha", "price": "10.000", "units": 7},
      {"name": "Hazelnut", "price": "5.000", "units": 6},
    ];
    final dailyRecent = [
      {
        "name": "Michael Chen",
        "total": "55.000",
        "items": "1x Cappucino\n2x Americano",
        "time": "15.22"
      },
      {
        "name": "Sarah Johnson",
        "total": "125.000",
        "items": "5x Matcha Latte\n2x Hazelnut",
        "time": "15.32"
      },
      {
        "name": "Emily",
        "total": "129.000",
        "items": "4x Red Velvet\n2x Hazelnut",
        "time": "15.32"
      },
    ];
    final daily = [
      const SizedBox(height: 8),
      GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        children: const [
          SummaryCard(
            title: "Total Sales",
            amount: "500.000",
            subtitle: "",
            icon: Icons.bar_chart,
          ),
          SummaryCard(
            title: "Transaction",
            amount: "8",
            subtitle: "",
            icon: Icons.receipt_long,
          ),
          SummaryCard(
            title: "Item Sold",
            amount: "32",
            subtitle: "",
            icon: Icons.shopping_bag,
          ),
          SummaryCard(
            title: "Customer",
            amount: "12",
            subtitle: "",
            icon: Icons.person,
          ),
        ],
      ),
      const SizedBox(height: 16),
      TopSellingList(items: topSellingData),
      const SizedBox(height: 16),
      RecentTransactions(transactions: dailyRecent),
      const SizedBox(height: 80),
    ];
    final weeklyRecent = [
      {
        "name": "Celine Parker",
        "total": "65.000",
        "items": "2x Latte\n1x Americano",
        "time": "16:22"
      },
      {
        "name": "Jacob",
        "total": "125.000",
        "items": "3x Matcha Latte\n1x Hazelnut",
        "time": "16:02"
      },
    ];
    final weekly = [
      const SizedBox(height: 8),
      GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, 
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        children: const [
          SummaryCard(
            title: "Total Sales",
            amount: "1.000.000",
            subtitle: "",
            icon: Icons.bar_chart,
          ),
          SummaryCard(
            title: "Transaction",
            amount: "16",
            subtitle: "",
            icon: Icons.receipt_long,
          ),
          SummaryCard(
            title: "Item Sold",
            amount: "64",
            subtitle: "",
            icon: Icons.shopping_bag,
          ),
          SummaryCard(
            title: "Customer",
            amount: "24",
            subtitle: "",
            icon: Icons.person,
          ),
        ],
      ),
      const SizedBox(height: 16),
      TopSellingList(items: topSellingData),
      const SizedBox(height: 16),
      RecentTransactions(transactions: weeklyRecent),
      const SizedBox(height: 80),
    ];
    final monthlySelling = [
      {"name": "Ice Tea", "price": "25.000", "units": 12},
      {"name": "Ice Black", "price": "20.000", "units": 10},
      {"name": "Jasmine Tea", "price": "15.000", "units": 8},
      {"name": "Green Shake", "price": "10.000", "units": 5},
      {"name": "Yunlu", "price": "5.000", "units": 4},
    ];
    final monthlyRecent = [
      {
        "name": "Andy",
        "total": "85.000",
        "items": "2x Matcha\n1x Red Velvet",
        "time": "16:22"
      },
      {
        "name": "Cally",
        "total": "135.000",
        "items": "3x Ice Black\n1x Green Shake",
        "time": "18:22"
      },
    ];
    final monthly = [
      const SizedBox(height: 8),
      GridView(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // 2 kolom
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.6,
        ),
        children: const [
          SummaryCard(
            title: "Total Sales",
            amount: "1.500.000",
            subtitle: "",
            icon: Icons.bar_chart,
          ),
          SummaryCard(
            title: "Transaction",
            amount: "32",
            subtitle: "",
            icon: Icons.receipt_long,
          ),
          SummaryCard(
            title: "Item Sold",
            amount: "128",
            subtitle: "",
            icon: Icons.shopping_bag,
          ),
          SummaryCard(
            title: "Customer",
            amount: "36",
            subtitle: "",
            icon: Icons.person,
          ),
        ],
      ),
      const SizedBox(height: 16),
      TopSellingList(items: monthlySelling),
      const SizedBox(height: 16),
      RecentTransactions(transactions: monthlyRecent),
      const SizedBox(height: 80),
    ];
    return ReportTabView(
      dailyContent: daily,
      weeklyContent: weekly,
      monthlyContent: monthly,
    );
  }
}
