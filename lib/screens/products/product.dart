import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/product_service.dart';
import 'package:aplikasi_lattelink/widgets/products/product_card.dart';
import '../../widgets/products/add_product_dialog.dart';
import '../../widgets/products/edit_product_dialog.dart';
import '../../widgets/sidebar_menu.dart';

const Color primaryColor = Color(0xFF6E200D);

class ProductPage extends StatefulWidget {
  const ProductPage({super.key});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  final ProductService productService = ProductService();

  List<Map<String, dynamic>> products = [];
  bool isLoading = true;

  int selectedFilter = 0;
  final TextEditingController searchController = TextEditingController();
  String searchQuery = "";

  // Filter kategori dinamis
  List<String> filterNames = ["All Items"];

  @override
  void initState() {
    super.initState();
    loadProducts();
  }

  Future<void> loadProducts() async {
    setState(() => isLoading = true);

    final data = await productService.getProducts();

    // Ambil kategori unik dari Supabase (SEMUA kategori, bukan hanya index 0!)
    Set<String> categorySet = {};
    for (var p in data) {
      final categories = p["categories"] as List<dynamic>?;

      if (categories != null && categories.isNotEmpty) {
        for (var c in categories) {
          final name = c["name"];
          if (name != null) {
            categorySet.add(name.toString());
          }
        }
      }
    }

    setState(() {
      products = data;
      filterNames = ["All Items", ...categorySet]; // Tambahkan ke filter
      isLoading = false;
    });
  }

  /// FILTER PRODUK
  List<Map<String, dynamic>> get filteredProducts {
    List<Map<String, dynamic>> list = products;

    // Filter kategori
    if (selectedFilter != 0) {
      String selected = filterNames[selectedFilter];

      list = list.where((p) {
        final categoriesList = p["categories"] as List<dynamic>?;

        // produk bisa punya banyak kategori → cocokkan salah satu
        if (categoriesList != null && categoriesList.isNotEmpty) {
          return categoriesList.any(
              (c) => c["name"].toString().toLowerCase() == selected.toLowerCase());
        }

        return false;
      }).toList();
    }

    // Filter search
    if (searchQuery.isNotEmpty) {
      list = list
          .where((p) => (p["name"] ?? "")
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase()))
          .toList();
    }

    return list;
  }

  void _openSidebar(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height * 0.85,
          margin: const EdgeInsets.only(top: 50, bottom: 120),
          child: const Material(
            child: SidebarMenu(selected: "product"),
          ),
        ),
      ),
    );
  }

  // TOP MESSAGE
  void showSuccessMessage(String message) {
    OverlayEntry entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        left: MediaQuery.of(context).size.width * 0.1,
        right: MediaQuery.of(context).size.width * 0.1,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(entry);
    Future.delayed(const Duration(seconds: 2)).then((_) => entry.remove());
  }

  Future<bool> confirmDelete(BuildContext context) async {
    return await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: Color(0xFFB05B3B), width: 2),
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              "Delete Product",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 32,
                color: Colors.black,
              ),
            ),
            content: const Text(
              "Are you sure you want to delete this product?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 24),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFFB05B3B), width: 2),
                      ),
                      child: const Text(
                        "Cancel",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 24),
                      decoration: BoxDecoration(
                        color: primaryColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Color(0xFFB05B3B), width: 2),
                      ),
                      child: const Text(
                        "Delete",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;

            return Padding(
              padding: const EdgeInsets.only(
                  top: 24, left: 20, right: 20, bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // HEADER
                  Row(
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.menu, color: primaryColor, size: 32),
                        onPressed: () => _openSidebar(context),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        "Product",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // SEARCH + ADD BUTTON
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                                color: Color(0xFFAFACAC), width: 2),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search,
                                  color: Color(0xFFAFACAC)),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: searchController,
                                  onChanged: (v) =>
                                      setState(() => searchQuery = v),
                                  decoration: const InputDecoration(
                                    hintText: "Search...",
                                    border: InputBorder.none,
                                    isDense: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () async {
                          final refresh = await showDialog(
                            context: context,
                            builder: (_) => const AddProductDialog(),
                          );

                          if (refresh == true) {
                            await loadProducts();
                            showSuccessMessage("Add Product Success !");
                          }
                        },
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Icon(Icons.add,
                                color: Colors.white, size: 28),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // FILTER BUTTONS
                  SizedBox(
                    height: 44,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: filterNames.length,
                      itemBuilder: (context, index) {
                        final selected = selectedFilter == index;
                        return GestureDetector(
                          onTap: () => setState(() => selectedFilter = index),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 8),
                            decoration: BoxDecoration(
                              color:
                                  selected ? primaryColor : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              filterNames[index],
                              style: TextStyle(
                                color: selected ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // PRODUCT GRID
                  Expanded(
                    child: isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : GridView.builder(
                            itemCount: filteredProducts.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.85,
                            ),
                            itemBuilder: (context, index) {
                              final p = filteredProducts[index];

                              final name = (p["name"] ?? "").toString();

                              int price = 0;
                              final rawPrice = p["price"];
                              if (rawPrice is int)
                                price = rawPrice;
                              else if (rawPrice is double)
                                price = rawPrice.toInt();
                              else if (rawPrice is String)
                                price = int.tryParse(rawPrice) ?? 0;

                              final imageUrl =
                                  (p["image"] ?? p["image_url"] ?? "")
                                      .toString();

                              final category = (() {
                                final categoriesList =
                                    p["categories"] as List<dynamic>?;
                                if (categoriesList != null &&
                                    categoriesList.isNotEmpty) {
                                  return categoriesList[0]["name"].toString();
                                }
                                return "-";
                              })();

                              return ProductCard(
                                name: name,
                                price: price,
                                imageUrl: imageUrl,
                                category: category,
                                onEdit: () async {
                                  final refresh = await showDialog(
                                    context: context,
                                    builder: (_) =>
                                        EditProductDialog(product: p),
                                  );

                                  if (refresh == true) {
                                    await loadProducts();
                                    showSuccessMessage(
                                        "Edit Product Success !");
                                  }
                                },
                                onDelete: () async {
  final id = p["id"]; // ← ini yang benar

  if (id == null) return;

  // Pop-up konfirmasi
  final bool confirm = await confirmDelete(context);
  if (!confirm) return;

  try {
    // Hapus dari Supabase
    await Supabase.instance.client
        .from('products')
        .delete()
        .eq('id', id); // ← pakai kolom yang benar

    // Refresh UI
    await loadProducts();

    // Notifikasi sukses
    showSuccessMessage("Delete product success !");
  } catch (e) {
    print("Delete error: $e");
  }
},
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
