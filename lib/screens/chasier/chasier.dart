import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../models/product_model.dart';
import '../../widgets/chasier_product.dart';
import '../../widgets/sidebar_menu.dart';
import 'package:aplikasi_lattelink/screens/chasier/Shopping_cart_page.dart';

const Color primaryColor = Color(0xFF6E200D);

class CashierPage extends StatefulWidget {
  const CashierPage({super.key});

  @override
  State<CashierPage> createState() => _CashierPageState();
}

class _CashierPageState extends State<CashierPage> {
  final supabase = Supabase.instance.client;

  int selectedFilter = 0;
  String searchQuery = "";
  final TextEditingController searchController = TextEditingController();

  List<ProductModel> allProducts = [];
  bool isLoading = true;

  List<Map<String, dynamic>> cartItems = [];

  final List<String> filterNames = [
    "All Items",
    "Coffee",
    "Non Coffee",
    "Snack",
    "Main Course",
    "Signature",
  ];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final List data = await supabase
          .from('products')
          .select('*, categories(*)')
          .order('id', ascending: true);

      setState(() {
        allProducts = data.map((e) => ProductModel.fromMap(e)).toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching products: $e');
      setState(() => isLoading = false);
    }
  }

  void addToCart(ProductModel product) {
    final index = cartItems.indexWhere((item) => item['id'] == product.id);

    if (index >= 0) {
      cartItems[index]['qty'] += 1;
    } else {
      cartItems.add({
        'id': product.id,
        'name': product.name,
        'price': product.price,
        'discount': product.discount,
        'qty': 1,
        'image_url': product.imageUrl,
      });
    }

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${product.name} ditambahkan ke keranjang"),
        duration: const Duration(seconds: 1),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> placeOrderToSupabase({
    required List<Map<String, dynamic>> cartItems,
    required String customerName,
    required String paymentMethod,
    required int subtotal,
    required int discount,
    required int grandTotal,
  }) async {
    final supabase = Supabase.instance.client;

    try {
      if (customerName.trim().isEmpty) {
        throw Exception("Nama customer tidak boleh kosong!");
      }

      final existing = await supabase
          .from('customers')
          .select()
          .eq('name', customerName)
          .maybeSingle();

      int customerId;

      if (existing != null) {
        customerId = existing['customers_id'];
      } else {
        final inserted = await supabase
            .from('customers')
            .insert({'name': customerName, 'phone': null, 'address': null})
            .select()
            .single();

        customerId = inserted['customers_id'];
      }

      final user = supabase.auth.currentUser;
      if (user == null) throw Exception("User tidak login!");

      final orderInsert = await supabase
          .from('orders')
          .insert({
            'customers_id': customerId,
            'user_id': user.id,
            'payment_method': paymentMethod,
            'discount_total': discount,
            'total_price': grandTotal,
          })
          .select()
          .single();

      final int orderId = orderInsert['order_id'];

      for (var item in cartItems) {
        await supabase.from('order_details').insert({
          'order_id': orderId,
          'product_id': item['id'],
          'quantity': item['qty'],
          'price': item['price'],
          'discount': item['discount'] ?? 0,
        });
      }

      print("Order sukses ✔");
    } catch (e) {
      print("ERROR ORDER: $e");
      rethrow;
    }
  }

  void _openCustomSidebar(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: size.width * 0.75,
              height: size.height * 0.85,
              margin: const EdgeInsets.only(top: 50, bottom: 120),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                child: Material(
                  color: Colors.white,
                  child: SidebarMenu(selected: "chasier"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<ProductModel> filteredProducts = allProducts.where((p) {
      final matchFilter =
          selectedFilter == 0 ||
          (selectedFilter == 1 && p.categoryName == "Coffee") ||
          (selectedFilter == 2 && p.categoryName == "Non Coffee") ||
          (selectedFilter == 3 && p.categoryName == "Snack") ||
          (selectedFilter == 4 && p.categoryName == "Main Course") ||
          (selectedFilter == 5 && p.categoryName == "Signature");

      final matchSearch = p.name.toLowerCase().contains(
        searchQuery.toLowerCase(),
      );

      return matchFilter && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(70),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 25, left: 25),
            child: AppBar(
              titleSpacing: 0,
              elevation: 0,
              backgroundColor: Colors.white,
              surfaceTintColor: Colors.white,
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.menu, color: primaryColor, size: 28),
                    onPressed: () => _openCustomSidebar(context),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    "Chasier",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.shopping_cart,
                      color: primaryColor,
                      size: 28,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ShoppingCartPage(cartItems: cartItems),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30,
                    vertical: 15,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 56,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFFAFACAC),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.search, color: Color(0xFFAFACAC)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: TextField(
                                controller: searchController,
                                onChanged: (value) =>
                                    setState(() => searchQuery = value),
                                decoration: const InputDecoration(
                                  hintText: "Search...",
                                  hintStyle: TextStyle(
                                    color: Color(0xFFAFACAC),
                                    fontSize: 20,
                                  ),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      const Text(
                        "Products",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      SizedBox(
                        height: 45,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: filterNames.length,
                          itemBuilder: (context, index) {
                            bool isSelected = selectedFilter == index;

                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedFilter = index),
                              child: Container(
                                margin: const EdgeInsets.only(right: 10),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 22,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? primaryColor
                                      : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  filterNames[index],
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: GridView.builder(
                      itemCount: filteredProducts.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            mainAxisExtent: 258,
                            crossAxisSpacing: 15,
                            mainAxisSpacing: 15,
                          ),
                      itemBuilder: (_, i) {
                        return ChasierProduct(
                          product: filteredProducts[i],
                          onAddToCart: () => addToCart(filteredProducts[i]),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
