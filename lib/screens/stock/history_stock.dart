import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final supabase = Supabase.instance.client;
  List historyList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    try {
      final res = await supabase
          .from("stock_histories")
          .select(
            "id, change, before_stock, after_stock, created_at, product_id, products (name, image_url)",
          )
          .order("created_at", ascending: false);

      setState(() {
        historyList = res;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR HISTORY: $e");
      setState(() => isLoading = false);
    }
  }

  String formatDate(String date) {
    return DateFormat("dd/MM/yyyy").format(DateTime.parse(date));
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double topPadding = screenWidth < 600 ? 30 : 60;
    final double sidePadding = screenWidth < 600 ? 20 : 40;
    final double imageSize = screenWidth < 600 ? 50 : 60;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
          top: topPadding,
          left: sidePadding,
          right: sidePadding,
          bottom: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.arrow_back_ios, size: 26),
                ),
                const SizedBox(width: 12),
                Text(
                  "History",
                  style: GoogleFonts.poppins(
                    fontSize: screenWidth < 600 ? 20 : 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 15,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFF6E200D).withOpacity(.4),
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : historyList.isEmpty
                    ? Center(
                        child: Text(
                          "No history recorded",
                          style: GoogleFonts.poppins(
                            color: Colors.black54,
                            fontSize: screenWidth < 600 ? 14 : 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: historyList.length,
                        itemBuilder: (_, i) {
                          final h = historyList[i];
                          final p = h["products"] ?? {};
                          final img = p["image_url"];
                          final name = p["name"] ?? "-";
                          return Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: imageSize,
                                    height: imageSize,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(14),
                                      child: img == null
                                          ? const Icon(Icons.image, size: 28)
                                          : Image.network(
                                              img,
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          name,
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth < 600
                                                ? 15
                                                : 17,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          "${h["change"] > 0 ? "+" : ""}${h["change"]}",
                                          style: GoogleFonts.poppins(
                                            fontSize: screenWidth < 600
                                                ? 14
                                                : 15,
                                            color: h["change"] > 0
                                                ? Colors.green
                                                : Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        formatDate(h["created_at"]),
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          fontSize: screenWidth < 600 ? 13 : 15,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        "Stock : ${h["after_stock"]}",
                                        style: GoogleFonts.poppins(
                                          color: Colors.black54,
                                          fontSize: screenWidth < 600 ? 12 : 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Divider(color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                            ],
                          );
                        },
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
