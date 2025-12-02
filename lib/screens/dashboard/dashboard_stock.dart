import 'package:flutter/material.dart';
import 'package:aplikasi_lattelink/widgets/dashboard/info_card.dart';
import 'package:aplikasi_lattelink/widgets/stock_table.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'dashboard.dart';

class DashboardStock extends StatefulWidget {
  const DashboardStock({super.key});

  @override
  State<DashboardStock> createState() => _DashboardStockState();
}

class _DashboardStockState extends State<DashboardStock> {
  final supabase = Supabase.instance.client;

  List<Map<String, String>> products = [];
  bool loading = true;

  RealtimeChannel? channel;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    setupRealtime(); // realtime supabase
  }

  // ==============================
  //    FETCH DATA DARI SUPABASE
  // ==============================
  Future<void> fetchProducts() async {
    try {
      final data = await supabase.from('products').select('name, stock');

      setState(() {
        products = data.map((item) {
          return {
            "name": item["name"].toString(),
            "stock": item["stock"].toString(),
          };
        }).toList();

        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetch products: $e");
      setState(() => loading = false);
    }
  }

  // ==============================
  //      REALTIME SUPABASE
  // ==============================
  void setupRealtime() {
    channel = supabase
        .channel('products-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all, // insert, update, delete
          schema: 'public',
          table: 'products',
          callback: (payload) {
            fetchProducts(); // refresh data otomatis
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    channel?.unsubscribe();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isSmall = width < 360;

        final double paddingHorizontal = isSmall ? 16 : 28;
        final double titleFont = isSmall ? 18 : 24;
        final double spacingBig = isSmall ? 20 : 40;
        final double spacingMedium = isSmall ? 14 : 26;

        return Scaffold(
          backgroundColor: Colors.white,

          // ============================================================
          //                        FIXED HEADER
          // ============================================================
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(70),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 25, left: 25),
                child: AppBar(
                  elevation: 0,
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const DashboardScreen()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.arrow_back,
                            size: 28, color: Colors.black),
                      ),
                      SizedBox(width: isSmall ? 10 : 20),
                      Text(
                        "Stock",
                        style: TextStyle(
                          fontSize: titleFont,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // ============================================================
          //                           CONTENT
          // ============================================================
          body: SingleChildScrollView(
            padding: EdgeInsets.only(
              left: paddingHorizontal,
              right: paddingHorizontal,
              top: isSmall ? 10 : 20,
              bottom: 20,
            ),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 850),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const DashboardCards(activeCard: "stock"),

                    SizedBox(height: spacingMedium),

                    Text(
                      "Stock Product",
                      style: TextStyle(
                        fontSize: isSmall ? 16 : 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    SizedBox(height: spacingMedium),

                    // LOADING
                    if (loading)
                      const Center(child: CircularProgressIndicator())
                    else
                      StockTable(products: products),

                    SizedBox(height: spacingBig),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
