class PaymentSuccessData {
  final int orderId;
  final int total;
  final int subtotal;
  final int discountTotal;
  final String paymentMethod;
  final String customer;
  final String cashier;
  final String date;
  final List<Map<String, dynamic>> items;

  PaymentSuccessData({
    required this.orderId,
    required this.total,
    required this.subtotal,
    required this.discountTotal,
    required this.paymentMethod,
    required this.customer,
    required this.cashier,
    required this.date,
    required this.items,
  });
}
