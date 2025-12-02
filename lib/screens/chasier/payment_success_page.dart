import 'package:flutter/material.dart';
import '../../models/payment_success_data.dart';

class PaymentSuccessPage extends StatelessWidget {
  final PaymentSuccessData data;

  const PaymentSuccessPage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0x8AB05B3B),
      body: Center(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 60),
              width: 360,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFF6E200D),
                  width: 3,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 55),

                  const Text(
                    "Payment Success",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    "Rp ${data.total}",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Divider(thickness: 2),
                  const SizedBox(height: 15),

                  _detailRow("Transaction Code", data.orderId.toString()),
                  _detailRow("Cashier", data.cashier),
                  _detailRow("Date", data.date),
                  _detailRow("Customer", data.customer),
                  _detailRow("Payment Method", data.paymentMethod),

                  const Divider(height: 30),

                  for (var item in data.items) ...[
                    _itemDetail(
                      item["name"],
                      "${item["qty"]} x ${item["price"]}",
                      item["total"].toString(),
                    ),
                    const SizedBox(height: 10),
                  ],

                  const Divider(height: 30),

                  _detailRow("Discount", data.discountTotal.toString()),
                  _detailRow("Subtotal", data.subtotal.toString()),
                  _detailRow("Total", data.total.toString(),
                      bold: true, big: true),

                  const SizedBox(height: 25),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0x8AB05B3B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Close",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(
                        width: 120,
                        height: 45,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0x8AB05B3B),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {},
                          child: const Text(
                            "Print",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),

            Container(
              width: 114,
              height: 114,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 12,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  color: Color(0xFF48742C),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_rounded,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _detailRow(String left, String right,
    {bool bold = false, bool big = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: const TextStyle(fontSize: 16)),
        Text(
          right,
          style: TextStyle(
            fontSize: big ? 19 : 16,
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

Widget _itemDetail(String title, String qty, String price) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(qty),
          Text(price),
        ],
      ),
    ],
  );
}
