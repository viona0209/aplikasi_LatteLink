import 'dart:typed_data';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class ProductService {
  final supabase = Supabase.instance.client;
  Future<List<Map<String, dynamic>>> getProducts() async {
    final data = await supabase
        .from('products')
        .select(
          'id, name, price, stock, discount, image_url, categories_id, categories:categories_id(name)',
        )
        .order('id');

    return data.map((p) {
      final categoryData = p['categories'];
      List<Map<String, dynamic>> categoriesList = [];

      if (categoryData != null &&
          categoryData is Map &&
          categoryData.containsKey('name')) {
        categoriesList.add({"name": categoryData['name'].toString()});
      }

      return {
        "id": p['id'],
        "name": p['name'],
        "price": p['price'],
        "stock": p['stock'],
        "discount": p['discount'],
        "image_url": p['image_url'],
        "categories_id": p['categories_id'],
        "categories": categoriesList,
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    final data = await supabase
        .from('categories')
        .select()
        .order('categories_id');

    return List<Map<String, dynamic>>.from(data);
  }

  Future<String?> pickAndUploadImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result == null) return null;

      final file = result.files.first;
      Uint8List? bytes;

      if (kIsWeb) {
        bytes = file.bytes;
        if (bytes == null) return null;
      } else {
        if (file.path == null) return null;
        bytes = await File(file.path!).readAsBytes();
      }

      return await uploadImage(file.name, bytes);
    } catch (e) {
      print("PICK IMAGE ERROR: $e");
      return null;
    }
  }

  Future<String?> uploadImage(String originalName, Uint8List bytes) async {
    try {
      final fileName = "${DateTime.now().millisecondsSinceEpoch}_$originalName";

      await supabase.storage
          .from('items')
          .uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      return supabase.storage.from('items').getPublicUrl(fileName);
    } catch (e) {
      print("UPLOAD IMAGE ERROR: $e");
      return null;
    }
  }

  String? get currentUserId {
    final user = supabase.auth.currentUser;
    return user?.id;
  }

  Future<bool> addProduct(Map<String, dynamic> data) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception("User belum login");

      final response = await supabase
          .from('products')
          .insert({
            "name": data["name"],
            "price": data["price"],
            "stock": data["stock"],
            "discount": data["discount"],
            "categories_id": data["categories_id"],
            "image_url": data["image_url"],
          })
          .select()
          .single();

      final int productId = response['id'];
      final int stock = response['stock'];

      await supabase.from('stock_histories').insert({
        'product_id': productId,
        'user_id': userId,
        'change': stock,
        'before_stock': 0,
        'after_stock': stock,
      });

      return true;
    } catch (e) {
      print("ADD PRODUCT ERROR: $e");
      return false;
    }
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    try {
      final userId = currentUserId;
      if (userId == null) throw Exception("User belum login");
      final productData = await supabase
          .from('products')
          .select('stock')
          .eq('id', id)
          .maybeSingle();
      int oldStock = productData != null && productData['stock'] != null
          ? productData['stock']
          : 0;
      int newStock = data['stock'] ?? oldStock;
      await supabase
          .from('products')
          .update({
            "name": data["name"],
            "price": data["price"],
            "stock": newStock,
            "discount": data["discount"],
            "categories_id": data["categories_id"],
            "image_url": data["image_url"],
          })
          .eq("id", id);

      if (newStock != oldStock) {
        await supabase.from('stock_histories').insert({
          'product_id': id,
          'user_id': userId,
          'change': newStock - oldStock,
          'before_stock': oldStock,
          'after_stock': newStock,
        });
      }

      return true;
    } catch (e) {
      print("UPDATE PRODUCT ERROR: $e");
      return false;
    }
  }

  Future<bool> deleteProduct(int id) async {
    try {
      await supabase.from('products').delete().eq("id", id);
      return true;
    } catch (e) {
      print("DELETE PRODUCT ERROR: $e");
      return false;
    }
  }

  Future<bool> updateStock(int productId, int change, String userId) async {
    try {
      final productData = await supabase
          .from('products')
          .select('stock')
          .eq('id', productId)
          .maybeSingle();
      int oldStock = productData != null && productData['stock'] != null
          ? productData['stock']
          : 0;
      int newStock = oldStock + change;
      await supabase
          .from('products')
          .update({'stock': newStock})
          .eq('id', productId);
      await supabase.from('stock_histories').insert({
        'product_id': productId,
        'user_id': userId,
        'change': change,
        'before_stock': oldStock,
        'after_stock': newStock,
      });
      return true;
    } catch (e) {
      print("UPDATE STOCK ERROR: $e");
      return false;
    }
  }
}
