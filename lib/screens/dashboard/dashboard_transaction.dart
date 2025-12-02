import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/dashboard/info_card.dart';
import 'dashboard.dart';

class DashboardTransaction extends StatefulWidget {
  const DashboardTransaction({super.key});

  @override
  State<DashboardTransaction> createState() => _DashboardTransactionState();
}

class _DashboardTransactionState extends State<DashboardTransaction> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransactions();
    setupRealtime();
  }

  // ================================================================
  //                      FETCH DATA DARI DATABASE
  // ================================================================
  Future<void> fetchTransactions() async {
    try {
      final res = await supabase
          .from('orders')
          .select()
          .order('created_at', ascending: false);

      setState(() {
        transactions = List<Map<String, dynamic>>.from(res);
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR FETCH TRANSACTION: $e");
      setState(() => isLoading = false);
    }
  }

  // ================================================================
  //                        REALTIME LISTENER
  // ================================================================
  void setupRealtime() {
    supabase.channel('orders_changes').onPostgresChanges(
      event: PostgresChangeEvent.insert,
      schema: 'public',
      table: 'orders',
      callback: (payload) {
        fetchTransactions();
      },
    ).subscribe();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        final bool isSmall = width < 360;

        final double paddingHorizontal = isSmall ? 16 : 28;
        final double titleFont = isSmall ? 18 : 24;
        final double itemFont = isSmall ? 16 : 22;
        final double statusFont = isSmall ? 16 : 22;

        final double spacingBig = isSmall ? 20 : 40;
        final double spacingMedium = isSmall ? 14 : 26;

        return Scaffold(
          backgroundColor: Colors.white,

          // =============================================================
          //                        HEADER
          // =============================================================
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
                            MaterialPageRoute(builder: (_) => const DashboardScreen()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Icons.arrow_back, size: 28, color: Colors.black),
                      ),

                      SizedBox(width: isSmall ? 10 : 20),
                      Text(
                        "Transaction",
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

          // =============================================================
          //                        BODY
          // =============================================================
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
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
                          const DashboardCards(activeCard: "transaction"),

                          SizedBox(height: spacingMedium),

                          Text(
                            "Transactions",
                            style: TextStyle(
                              fontSize: isSmall ? 16 : 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),

                          SizedBox(height: spacingMedium),

                          // =====================================================
                          //                  TRANSACTION LIST
                          // =====================================================
                          Column(
                            children: transactions.map((data) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: EdgeInsets.symmetric(
                                  vertical: isSmall ? 18 : 25,
                                  horizontal: isSmall ? 18 : 24,
                                ),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(18),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.08),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.15),
                                      blurRadius: 4,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // -------- NAME & AMOUNT ----------
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          data["customer_name"] ?? "Unknown",
                                          style: TextStyle(
                                            fontSize: itemFont,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        Text(
                                          "Rp ${data["total_"]}",
                                          style: TextStyle(
                                            fontSize: itemFont,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    // -------- TIME & STATUS ----------
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          data["created_at"]?.toString().substring(11, 16) ?? "",
                                          style: TextStyle(
                                            fontSize: statusFont,
                                            color: const Color(0xFF474747),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          data["status"] ?? "Done",
                                          style: TextStyle(
                                            fontSize: statusFont,
                                            color: const Color(0xFF474747),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),

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
