class ProductModel {
  final int id;
  final String name;
  final int price;
  final String imageUrl;
  final String categoryName;
  final int discount; 

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.categoryName,
    required this.discount,
  });

  factory ProductModel.fromMap(Map<String, dynamic> data) {
    return ProductModel(
      id: data['id'],
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
      imageUrl: data['image_url'] ?? '',
      categoryName: data['categories']?['name'] ?? '',
      discount: data['discount'] ?? 0,
    );
  }
}
