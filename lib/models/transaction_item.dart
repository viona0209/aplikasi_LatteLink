class TransactionItem {
  final String name;
  final String date;
  final int total;

  TransactionItem({
    required this.name,
    required this.date,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "date": date,
      "total": total,
    };
  }
}
