import 'package:supabase_flutter/supabase_flutter.dart';

class ProductService {
  final supabase = Supabase.instance.client;

Future<void> addProduct(String name, int price, int categoryId, int stock, {String? image}) async {
  await supabase.from('products').insert({
    'name': name,
    'price': price,
    'category_id': categoryId,
    'stock': stock,
    'image': image,
  });
}


  Future<List<Map<String, dynamic>>> getProducts() async {
    final response = await supabase.from('products').select();
    return (response as List).map((item) => item as Map<String, dynamic>).toList();
  }

  Future<void> updateProduct(int id, Map<String, dynamic> data) async {
    await supabase.from('products').update(data).eq('product_id', id);
  }

  Future<void> deleteProduct(int id) async {
    await supabase.from('products').delete().eq('product_id', id);
  }
}
