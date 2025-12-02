class TopProduct {
  final String name;
  final int units;
  final int price;

  TopProduct({
    required this.name,
    required this.units,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      "name": name,
      "units": units,
      "price": price,
    };
  }
}
