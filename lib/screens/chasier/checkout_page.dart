import 'dart:ui';
import 'package:aplikasi_lattelink/models/payment_success_data.dart';
import 'package:aplikasi_lattelink/screens/chasier/payment_success_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CheckoutPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final int subtotal;
  final int discount;
  final int grandTotal;

  final Function(String paymentMethod, String customerName) onConfirmOrder;

  const CheckoutPage({
    super.key,
    required this.cartItems,
    required this.subtotal,
    required this.discount,
    required this.grandTotal,
    required this.onConfirmOrder,
  });

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  String selectedPayment = "";
  final TextEditingController customerCtrl = TextEditingController();
  final format = NumberFormat("#,###", "id_ID");

  final supabase = Supabase.instance.client;
  List<dynamic> suggestions = [];
  bool showSuggestion = false;

  final RegExp nameRegex = RegExp(r"^[a-zA-Z\s\.\-']+$");

  Future<void> _searchCustomer(String keyword) async {
    if (keyword.trim().isEmpty) {
      setState(() {
        suggestions = [];
        showSuggestion = false;
      });
      return;
    }

    try {
      final res = await supabase
          .from('customers')
          .select()
          .ilike('name', '%$keyword%')
          .limit(10);

      setState(() {
        suggestions = res as List<dynamic>;
        showSuggestion = (res as List).isNotEmpty;
      });
    } catch (e) {
      setState(() {
        suggestions = [];
        showSuggestion = false;
      });
    }
  }

  Future<int> getOrCreateCustomer(String name) async {
    final existing = await supabase
        .from('customers')
        .select('')
        .eq('name', name)
        .maybeSingle();

    if (existing != null) {
      return existing['customers_id'];
    }

    final inserted = await supabase
        .from('customers')
        .insert({'name': name})
        .select('customers_id')
        .single();

    return inserted['customers_id'];
  }

  Future<void> placeOrderToSupabase({
    required List<Map<String, dynamic>> cartItems,
    required String customerName,
    required String paymentMethod,
    required int subtotal,
    required int discount,
    required int grandTotal,
  }) async {
    try {
      final trimmed = customerName.trim();
      if (trimmed.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Nama customer tidak boleh kosong")),
        );
        return;
      }

      final user = supabase.auth.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text("User belum login")));
        return;
      }

      final customerId = await getOrCreateCustomer(trimmed);

      final orderInsert = await supabase
          .from('orders')
          .insert({
            'customers_id': customerId,
            'user_id': user.id,
            'payment_method': paymentMethod,
            'discount_total': discount,
            'total_price': grandTotal,
          })
          .select()
          .single();

      final orderId = orderInsert['order_id'] as int;

      final details = cartItems.map((item) {
        return {
          'order_id': orderId,
          'product_id': item['id'],
          'quantity': item['qty'],
          'price': item['price'],
          'discount': item['discount'] ?? 0,
        };
      }).toList();

      await supabase.from('order_details').insert(details);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => PaymentSuccessPage(
            data: PaymentSuccessData(
              orderId: orderId,
              total: grandTotal,
              subtotal: subtotal,
              discountTotal: discount,
              paymentMethod: paymentMethod,
              customer: customerName,
              cashier: user.email ?? "Kasir",
              date: DateTime.now().toString(),
              items: cartItems.map((item) {
                return {
                  "name": item["name"],
                  "qty": item["qty"],
                  "price": item["price"],
                  "total": item["qty"] * item["price"],
                };
              }).toList(),
            ),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Gagal menyimpan order: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 380;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 30,
                    left: 24,
                    right: 24,
                    bottom: 8,
                  ),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back_ios, size: 24),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Detail Order",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Customer",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),

                      TextField(
                        controller: customerCtrl,
                        onChanged: _searchCustomer,
                        decoration: InputDecoration(
                          hintText: "Nama customer...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Nama harus huruf. Jika belum ada, akan dibuat baru.",
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ListView(
                      children: [
                        const SizedBox(height: 10),
                        const Text(
                          "Items",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 18),

                        ...widget.cartItems.map((item) {
                          final price = (item['price'] as num).toInt();
                          final total = price * item['qty'];

                          return Column(
                            children: [
                              _itemCard(
                                item['name'],
                                item['image_url'],
                                format.format(total),
                                item['qty'],
                                isSmall,
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade300,
                        blurRadius: 6,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _orderSummary(isSmall),

                      const SizedBox(height: 24),

                      SizedBox(
                        width: double.infinity,
                        height: isSmall ? 46 : 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6E200D),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            if (selectedPayment == "") {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Pilih metode pembayaran"),
                                ),
                              );
                              return;
                            }
                            if (customerCtrl.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Isi nama customer dulu"),
                                ),
                              );
                              return;
                            }

                            _showConfirmDialog();
                          },
                          child: Text(
                            "Konfirmasi Pembayaran",
                            style: TextStyle(
                              fontSize: isSmall ? 15 : 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            if (showSuggestion)
              Positioned(
                top: 115,
                left: 24,
                right: 24,
                child: Material(
                  elevation: 4,
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView(
                      shrinkWrap: true,
                      children: suggestions.map((c) {
                        return ListTile(
                          title: Text(c['name']),
                          onTap: () {
                            customerCtrl.text = c['name'];
                            setState(() => showSuggestion = false);
                          },
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _itemCard(String name, String img, String total, int qty, bool small) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              img,
              height: small ? 70 : 90,
              width: small ? 70 : 90,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: small ? 70 : 90,
                height: small ? 70 : 90,
                color: Colors.grey[200],
                child: const Icon(Icons.image_not_supported),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$name (x$qty)",
                  style: TextStyle(
                    fontSize: small ? 16 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text("Rp $total", style: TextStyle(fontSize: small ? 14 : 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _orderSummary(bool small) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Order Summary",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 18),

          _row("Subtotal", "Rp ${format.format(widget.subtotal)}", small),
          const SizedBox(height: 10),
          _row("Discount", "Rp ${format.format(widget.discount)}", small),

          const SizedBox(height: 18),
          const Divider(),
          const SizedBox(height: 18),

          _row(
            "Total",
            "Rp ${format.format(widget.grandTotal)}",
            small,
            bold: true,
            big: true,
          ),

          const SizedBox(height: 26),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _paymentButton("Cash", Icons.payments, "cash", small),
              _paymentButton("QRIS", Icons.qr_code_2, "qris", small),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(
    String l,
    String r,
    bool small, {
    bool bold = false,
    bool big = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: TextStyle(fontSize: small ? 15 : 17)),
        Text(
          r,
          style: TextStyle(
            fontSize: big ? (small ? 18 : 20) : (small ? 15 : 17),
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _paymentButton(String text, IconData icon, String value, bool small) {
    final selected = selectedPayment == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedPayment = value;
        });
      },
      child: Container(
        width: 120,
        height: 55,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF6E200D) : const Color(0xFFEED5CE),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: small ? 24 : 28,
              color: selected ? Colors.white : const Color(0xFF6E200D),
            ),
            Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF6E200D),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showConfirmDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Konfirmasi Transaksi",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                _dialogRow("Customer", customerCtrl.text),
                const SizedBox(height: 10),
                _dialogRow("Item", "${widget.cartItems.length} Product"),
                const SizedBox(height: 10),
                _dialogRow(
                  "Payment Method",
                  selectedPayment == "cash" ? "Tunai" : "QRIS",
                ),

                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),

                _dialogRow(
                  "Total",
                  "Rp${format.format(widget.grandTotal)}",
                  bold: true,
                ),

                const SizedBox(height: 26),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFEEC7B8),
                          foregroundColor: Colors.black87,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          Navigator.pop(context);

                          await placeOrderToSupabase(
                            cartItems: widget.cartItems,
                            customerName: customerCtrl.text,
                            paymentMethod: selectedPayment,
                            subtotal: widget.subtotal,
                            discount: widget.discount,
                            grandTotal: widget.grandTotal,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFF6E200D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          "Confirm",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _dialogRow(String left, String right, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: TextStyle(fontSize: 15, color: Colors.black87)),
        Text(
          right,
          style: TextStyle(
            fontSize: 15,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
