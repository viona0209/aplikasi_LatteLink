import 'package:flutter/material.dart';

class StockTable extends StatelessWidget {
  final List<Map<String, String>> products;

  const StockTable({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0x406E200D),
          width: 3.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ============ ROW JUDUL ===============
          Row(
            children: const [
              Expanded(
                flex: 3,
                child: Text(
                  "Produk",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  "Stock",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),

          const SizedBox(height: 7),

          // ============ GARIS HORIZONTAL FULL ===============
          Container(height: 0.5, color: Color(0xFFAFACAC)),

          // ============ TABEL PRODUK + GARIS VERTIKAL ===============
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ===== KOLOM PRODUK =====
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var item in products)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            item["name"]!,
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w400),
                          ),
                        ),
                    ],
                  ),
                ),

                // ===== GARIS VERTIKAL (mulai setelah garis horizontal) =====
                Container(
                  width: 0.5,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  color: Color(0xFFAFACAC),
                ),

                // ===== KOLOM STOCK =====
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      for (var item in products)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          child: Text(
                            item["stock"]!,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              color: Color(0xFF474747)
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
