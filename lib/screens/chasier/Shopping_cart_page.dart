import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'checkout_page.dart';

class ShoppingCartPage extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;

  const ShoppingCartPage({
    super.key,
    required this.cartItems,
  });

  @override
  State<ShoppingCartPage> createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  final currencyFormat = NumberFormat("#,###", "id_ID");
  final supabase = Supabase.instance.client;

  // ================================
  //   HITUNG TOTAL – FIXED
  // ================================
  int get totalPrice {
    return widget.cartItems.fold<int>(
      0,
      (sum, item) {
        final price = (item['price'] as num).toInt();
        final qty = item['qty'] as int;
        return sum + (price * qty);
      },
    );
  }

  int get discountTotal {
    return widget.cartItems.fold<int>(
      0,
      (sum, item) {
        final qty = item['qty'] as int;
        final discountNominal = (item['discount'] as num?)?.toInt() ?? 0;
        return sum + (discountNominal * qty);
      },
    );
  }

  int get subtotal => totalPrice;
  int get totalDiscount => discountTotal;
  int get grandTotal => totalPrice - discountTotal;

  // ======================================================
  //                  ORDER → SUPABASE
  // ======================================================
  Future<void> placeOrder(String paymentMethod, String customerName) async {
    try {
      final user = supabase.auth.currentUser;

      if (user == null) {
        throw Exception("User belum login");
      }

      int? customerId;

      if (customerName.isNotEmpty) {
        final customer = await supabase.from("customers").insert({
          "name": customerName,
        }).select().single();

        customerId = customer["customer_id"];
      }

      final order = await supabase.from("orders").insert({
        "customer_id": customerId,
        "user_id": user.id,
        "payment_method": paymentMethod,
        "discount_total": totalDiscount,
        "total_price": grandTotal,
      }).select().single();

      final orderId = order["order_id"];

      for (var item in widget.cartItems) {
        await supabase.from("order_details").insert({
          "order_id": orderId,
          "product_id": item["id"],
          "quantity": item["qty"],
          "price": item["price"],
          "discount": item["discount"] ?? 0,
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Order berhasil masuk Supabase!")),
      );

      Navigator.pop(context);
    } catch (e) {
      debugPrint("Error order: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal submit order: $e")),
      );
    }
  }

  void _showTopNotification(String message) {
  OverlayEntry overlayEntry;

  overlayEntry = OverlayEntry(
    builder: (context) {
      return Positioned(
        top: 40, // posisi dari atas
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Color(0xFF6E200D), // warna primary
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  // masukkan ke overlay
  Overlay.of(context).insert(overlayEntry);

  // hilangkan setelah 2 detik
  Future.delayed(const Duration(seconds: 2)).then((_) {
    overlayEntry.remove();
  });
}

  // ======================================================
  //              POPUP DELETE PRODUCT
  // ======================================================
  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Delete Product",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                const Text(
                  "Are you sure you want to delete this product?",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),

                const SizedBox(height: 26),

                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: const Color(0xFFE3B7A0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Cancel",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: TextButton(
                        onPressed: () {
  setState(() {
    widget.cartItems.removeAt(index);
  });
  Navigator.pop(context);
  _showTopNotification("Delete Success"); // ← panggil notifikasi
},
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: Color(0xFF6E200D),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Delete",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  // ======================================================
  //                       UI
  // ======================================================
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isSmall = width < 360;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        toolbarHeight: 95,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.only(top: 18),
          child: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Padding(
          padding: EdgeInsets.only(top: 15),
          child: Text(
            "Shopping Cart",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
        ),
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Text(
              "Item",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: widget.cartItems.length,
              itemBuilder: (context, index) {
                final item = widget.cartItems[index];
                final price = (item['price'] as num).toInt();

                return Slidable(
                  key: ValueKey(item['id']),
                  endActionPane: ActionPane(
                    extentRatio: 0.25,
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) => _showDeleteDialog(index),
                        backgroundColor: const Color(0xFF6E200D),
                        foregroundColor: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        icon: Icons.delete,
                        label: "Delete",
                      ),
                    ],
                  ),

                  child: Container(
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            item['image_url'] ?? "",
                            width: isSmall ? 55 : 70,
                            height: isSmall ? 55 : 70,
                            fit: BoxFit.cover,
                          ),
                        ),

                        SizedBox(width: isSmall ? 10 : 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item['name'],
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: isSmall ? 14 : 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                currencyFormat.format(price),
                                style: TextStyle(
                                  fontSize: isSmall ? 12 : 14,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              if (item['qty'] > 1) item['qty']--;
                            });
                          },
                          icon: const Icon(Icons.remove_circle_outline),
                        ),

                        Text(
                          item['qty'].toString(),
                          style: TextStyle(
                            fontSize: isSmall ? 14 : 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        IconButton(
                          onPressed: () {
                            setState(() {
                              item['qty']++;
                            });
                          },
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // SUMMARY
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.brown.shade100),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow("Subtotal :", subtotal),
                _buildSummaryRow("Diskon :", totalDiscount),
                const SizedBox(height: 12),
                const Divider(thickness: 1),
                const SizedBox(height: 8),
                _buildSummaryRow("Total :", grandTotal),
              ],
            ),
          ),

          // BUTTON ORDER
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 26, top: 4),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6E200D),
                  padding: EdgeInsets.symmetric(vertical: isSmall ? 14 : 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CheckoutPage(
                        cartItems: widget.cartItems,
                        subtotal: subtotal,
                        discount: totalDiscount,
                        grandTotal: grandTotal,
                        onConfirmOrder: placeOrder,
                      ),
                    ),
                  );
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Order",
                      style: TextStyle(fontSize: isSmall ? 16 : 18),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 15, color: Colors.black87)),
          Text(
            "Rp ${currencyFormat.format(value)}",
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
