import 'package:aplikasi_lattelink/widgets/reports/common_widget.dart';
import 'package:flutter/material.dart';

class TransactionsReportScreen extends StatelessWidget {
  const TransactionsReportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
  children: [
    TransactionDetailCard(
      name: "Michael Chen",
      datetime: "2025-10-19 15.22",
      payment: "Cash",
      total: "47.000",
      items: [
        {"label": "1 x Cappuccino", "price": "19.000"},
        {"label": "2 x Americano", "price": "38.000"},
      ],
    ),

    TransactionDetailCard(
      name: "Cally",
      datetime: "2025-10-19 15.32",
      payment: "Cash",
      total: "133.000",
      items: [
        {"label": "5 x Matcha Latte", "price": "95.000"},
        {"label": "2 x Hazelnut", "price": "38.000"},
      ],
    ),
  ],
)

      ),
    );
  }
}
