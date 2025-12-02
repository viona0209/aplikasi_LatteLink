import 'top_product.dart';
import 'transaction_item.dart';

class ReportDummy {
  static Map<String, int> getStats(int period) {
    return {
      "totalSales": 1250000,
      "transactions": 32,
      "itemsSold": 87,
      "customer": 29,
    };
  }

  static List<Map<String, dynamic>> getTopProducts(int period) {
    final List<TopProduct> list = [
      TopProduct(name: "Latte", units: 14, price: 22000),
      TopProduct(name: "Cappuccino", units: 9, price: 25000),
      TopProduct(name: "Es Kopi Susu", units: 11, price: 18000),
    ];

    return list.map((e) => e.toMap()).toList();
  }

  static List<Map<String, dynamic>> getRecent(int period) {
    final List<TransactionItem> recent = [
      TransactionItem(name: "Alya", date: "Today 12:30", total: 34000),
      TransactionItem(name: "Dewi", date: "Today 11:45", total: 28000),
      TransactionItem(name: "Budi", date: "Today 10:20", total: 56000),
    ];

    return recent.map((e) => e.toMap()).toList();
  }
}
