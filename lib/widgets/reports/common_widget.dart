import 'package:flutter/material.dart';


// =====================
// SUMMARY CARD
// =====================
class SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String subtitle;
  final IconData? icon;

  const SummaryCard({
    Key? key,
    required this.title,
    required this.amount,
    required this.subtitle,
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Color(0xFF6E200D),
          width: 1,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          if (icon != null)
            Positioned(
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Color(0xFFEDDEDA),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: Color(0xFF6E200D),
                  size: 20,
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (subtitle.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}

// =====================
// TOP SELLING PRODUCTS
// =====================
class TopSellingList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const TopSellingList({Key? key, required this.items}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF6E200D), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Top Selling Products",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...items.asMap().entries.map((e) {
            final index = e.key + 1;
            final name = e.value['name'];
            final price = e.value['price'];
            final units = e.value['units'];

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nomor ranking bulat
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      index.toString(),
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Nama & Units
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: const TextStyle(fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          "$units Units",
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),

                  // Harga
                  Text(
                    price,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          })
        ],
      ),
    );
  }
}

// =====================
// RECENT TRANSACTIONS
// =====================
class RecentTransactions extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;

  const RecentTransactions({Key? key, required this.transactions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFF6E200D), width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Transaction",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          ...transactions.map((t) {
            return Column(
              children: [
                Row(
                  children: [
                    // Nama customer
                    Expanded(
                      child: Text(
                        t['name'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),

                    // Harga
                    Text(
                      t['total'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                // Detail transaksi
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        t['items'],
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ),
                    Text(
                      t['time'],
                      style:
                          TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),

                const SizedBox(height: 12),
                Divider(color: Colors.grey.shade300),
              ],
            );
          })
        ],
      ),
    );
  }
}

// =====================
// TRANSACTION DETAIL CARD
// =====================
class TransactionDetailCard extends StatelessWidget {
  final String name;
  final String datetime;
  final String payment;
  final List<Map<String, String>> items;
  final String total;

   TransactionDetailCard({
    Key? key,
    required this.name,
    required this.datetime,
    required this.payment,
    required this.items,
    required this.total,
  }) : super(key: key);

  final Color primary = Color(0xFF6E200D);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // NAME + DATE
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                  ),
                ),
                Text(
                  datetime,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // DATE & TIME LABEL
            const Text(
              "Date & Time",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 3),

            // DATE VALUE
            Text(
              datetime,
              style: const TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 6),

            // PAYMENT METHOD LABEL
            const Text(
              "Payment Method",
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 3),

            // PAYMENT VALUE
            Text(
              payment,
              style: const TextStyle(fontSize: 13),
            ),

            const SizedBox(height: 14),

            // ITEMS LIST
            ...items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item["label"]!, style: const TextStyle(fontSize: 14)),
                    Text(item["price"]!, style: const TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // TOTAL
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Total",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                Text(
                  total,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // PRINT BUTTON
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.print, color: Colors.white, size: 18),
                  SizedBox(width: 6),
                  Text(
                    "Print",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}


// =====================
// PROFIT SUMMARY (PL)
// —=====================
class ProfitSummaryGrid extends StatelessWidget {
  final String revenue, cost, profit, percent;

  const ProfitSummaryGrid({
    super.key,
    required this.revenue,
    required this.cost,
    required this.profit,
    required this.percent,
  });

  final Color primary = const Color(0xFF6E200D);

  Widget summaryBox(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(label, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              const Spacer(),
              Icon(icon, size: 18, color: primary),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        summaryBox("Revenue", revenue, Icons.money),
        summaryBox("Costs", cost, Icons.receipt_long),
        summaryBox("Profit", profit, Icons.trending_up),
        summaryBox("Margin", percent, Icons.percent),
      ],
    );
  }
}

// ========================
// BAR CHART PLACEHOLDER
// ========================
class ProfitChartBox extends StatelessWidget {
  const ProfitChartBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "daily profit & loss",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),

          // Placeholder Chart
          SizedBox(
            height: 200,
            child: Center(
              child: Text(
                "Chart Placeholder",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Legend
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              legendDot(Colors.blue),
              const SizedBox(width: 4),
              const Text("Costs"),

              const SizedBox(width: 12),
              legendDot(Colors.red),
              const SizedBox(width: 4),
              const Text("Revenue"),

              const SizedBox(width: 12),
              legendDot(Colors.green),
              const SizedBox(width: 4),
              const Text("Profit"),
            ],
          ),
        ],
      ),
    );
  }

  Widget legendDot(Color c) {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
    );
  }
}

// ========================
// PROFIT DETAIL LIST
// ========================
class ProfitDetailList extends StatelessWidget {
  final List<Map<String, String>> data;

  ProfitDetailList({super.key, required this.data});

  final Color primary = const Color(0xFF6E200D);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Profit & loss detail",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),

          Column(
            children: data.asMap().entries.map((entry) {
              int index = entry.key + 1;
              var row = entry.value;

              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Number bubble
                    Container(
                      width: 32,
                      height: 32,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black26),
                      ),
                      child: Text(
                        index.toString(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            row["date"]!,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 4),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Revenue", style: TextStyle(color: Colors.grey)),
                              Text(row["revenue"]!),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Costs", style: TextStyle(color: Colors.red)),
                              Text(row["cost"]!, style: const TextStyle(color: Colors.red)),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Profit", style: TextStyle(color: Colors.green)),
                              Text(
                                row["profit"]!,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
