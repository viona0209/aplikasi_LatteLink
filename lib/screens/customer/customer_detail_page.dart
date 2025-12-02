import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

class CustomerDetailPage extends StatefulWidget {
  final String customerId;

  const CustomerDetailPage({super.key, required this.customerId});

  @override
  State<CustomerDetailPage> createState() => _CustomerDetailPageState();
}

class _CustomerDetailPageState extends State<CustomerDetailPage> {
  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> historyItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchHistory();
  }

  Future<void> fetchHistory() async {
    setState(() => isLoading = true);

    try {
      final data = await supabase
          .from('orders')
          .select('order_id, created_at, order_details(*, products(*))')
          .eq('customers_id', widget.customerId)
          .order('created_at', ascending: false);

      List<Map<String, dynamic>> temp = [];

      for (var order in data) {
        final createdAt = order['created_at'];
        final details = order['order_details'] as List;

        for (var item in details) {
          temp.add({
            'name': item['products']['name'],
            'price': item['price'],
            'qty': item['quantity'],
            'image': item['products']['image_url'] ?? '',
            'date': createdAt,
          });
        }
      }

      setState(() {
        historyItems = temp;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("ERROR FETCH HISTORY: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.only(top: 70, left: 20, right: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 28),
                  onPressed: () => Navigator.pop(context),
                ),
                const Text(
                  "History",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Main box
            Expanded(
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(
                          color: const Color(0xFF6E200D).withOpacity(0.3),
                          width: 2.5,
                        ),
                      ),
                      child: ListView.separated(
                        itemCount: historyItems.length,
                        separatorBuilder: (_, __) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            thickness: 1.2,
                            color:
                                const Color(0xFF6E200D).withOpacity(0.25),
                          ),
                        ),
                        itemBuilder: (context, index) {
                          final item = historyItems[index];

                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Image
                              Container(
                                width: 70,
                                height: 65,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.12),
                                      blurRadius: 10,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: item['image'] != ''
                                      ? Image.network(
                                          item['image'],
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(Icons.image, size: 32),
                                ),
                              ),
                              const SizedBox(width: 15),

                              // Name & price
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item['name'],
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Rp.${item['price']}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),

                              // Date & qty
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    DateFormat('dd/MM/yyyy').format(
                                        DateTime.parse(item['date'])),
                                    style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "quantity : ${item['qty']}",
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ],
                              ),
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
