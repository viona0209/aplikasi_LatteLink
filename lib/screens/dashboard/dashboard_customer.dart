import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/dashboard/info_card.dart';
import 'dashboard.dart';

class DashboardCustomer extends StatefulWidget {
  const DashboardCustomer({super.key});

  @override
  State<DashboardCustomer> createState() => _DashboardCustomerState();
}

class _DashboardCustomerState extends State<DashboardCustomer> {
  final supabase = Supabase.instance.client;

  List<String> customers = [];
  bool loading = true;

  RealtimeChannel? channel;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
    setupRealtime();
  }

  // ==========================
  //     FETCH CUSTOMER
  // ==========================
  Future<void> fetchCustomers() async {
    try {
      final data = await supabase.from('customers').select('name');

      setState(() {
        customers = data.map<String>((c) => c['name'].toString()).toList();
        loading = false;
      });
    } catch (e) {
      debugPrint("Error fetch customers: $e");
      setState(() => loading = false);
    }
  }

  // ==========================
  //       REALTIME
  // ==========================
  void setupRealtime() {
    channel = supabase
        .channel('customers-changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'customers',
          callback: (payload) {
            fetchCustomers(); // auto refresh
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    channel?.unsubscribe();
    super.dispose();
  }

  // ==========================
  //        UI LAYOUT
  // ==========================
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
                        "Customer",
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
                    const DashboardCards(activeCard: "customer"),

                    SizedBox(height: spacingMedium),

                    Text(
                      "Customer",
                      style: TextStyle(
                        fontSize: isSmall ? 16 : 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),

                    SizedBox(height: spacingMedium),

                    // LOADING
                    if (loading)
                      const Center(child: CircularProgressIndicator()),

                    // CUSTOMER LIST
                    if (!loading)
                      Column(
                        children: customers.map((name) {
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Name
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: itemFont,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),

                                // Status
                                Text(
                                  "Active",
                                  style: TextStyle(
                                    fontSize: statusFont,
                                    color: const Color(0xFF474747),
                                    fontWeight: FontWeight.w600,
                                  ),
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
