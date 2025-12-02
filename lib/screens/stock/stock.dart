import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/sidebar_menu.dart';
import 'history_stock.dart';

class StockPage extends StatefulWidget {
  const StockPage({super.key});

  @override
  State<StockPage> createState() => _StockPageState();
}

class _StockPageState extends State<StockPage> {
  final Color primary = const Color(0xFF6E200D);
  final TextEditingController searchC = TextEditingController();
  String searchQuery = "";

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> products = [];
  bool isLoading = false;

  final String fallbackAsset = 'assets/image/default_product.png';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    setState(() => isLoading = true);
    try {
      final data = await supabase
          .from('products')
          .select('id, name, stock, image_url, price, discount, categories_id')
          .order('name', ascending: true);

      products = (data as List)
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList();
    } catch (e) {
      debugPrint('FETCH PRODUCTS ERROR: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> updateProductStock({
  required int productId,
  required int before,
  required int after,
}) async {
  try {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      showSuccessToast('Sesi login hilang, silakan login ulang.');
      return;
    }

    /// 1. UPDATE STOCK by ID
    await supabase.from('products').update({
      'stock': after,
    }).eq('id', productId);

    /// 2. INSERT HISTORY (tabel yang benar: stock_histories)
    await supabase.from('stock_histories').insert({
      'product_id': productId,
      'user_id': userId,
      'change': after - before,
      'before_stock': before,
      'after_stock': after,
      'created_at': DateTime.now().toIso8601String(),
    });

    await fetchProducts();
    showSuccessToast('Updated Successfully');
  } catch (e) {
    debugPrint('UPDATE STOCK ERROR: $e');
    showSuccessToast('Update failed');
  }
}

  void showEditPopup(
    BuildContext context,
    Offset iconPos, {
    required int productId,
    required String name,
    required int stock,
    required Function() onDone,
  }) {
    OverlayState overlayState = Overlay.of(context);
    late OverlayEntry entry;

    TextEditingController nameC = TextEditingController(text: name);
    TextEditingController stockC =
        TextEditingController(text: stock.toString());

    entry = OverlayEntry(
      builder: (context) => Positioned(
        left: iconPos.dx - 230,
        top: iconPos.dy - 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            width: 260,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primary, width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.16),
                  offset: const Offset(0, 4),
                  blurRadius: 12,
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text("Edit Product",
                        style: GoogleFonts.poppins(
                            fontSize: 15, fontWeight: FontWeight.w600)),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => entry.remove(),
                      child: const Icon(Icons.close, size: 20),
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("Product Name",
                        style: GoogleFonts.poppins(fontSize: 13))),
                const SizedBox(height: 6),
                TextField(
                  controller: nameC,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                    alignment: Alignment.centerLeft,
                    child:
                        Text("Stock", style: GoogleFonts.poppins(fontSize: 13))),
                const SizedBox(height: 6),
                TextField(
                  controller: stockC,
                  keyboardType: TextInputType.number,
                  style: GoogleFonts.poppins(),
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () async {
                        final newName = nameC.text.trim();
                        final newStock =
                            int.tryParse(stockC.text.trim()) ?? stock;

                        try {
                          if (newName != name) {
                            await supabase
                                .from('products')
                                .update({'name': newName})
                                .eq('id', productId);// FIXED
                          }
                        } catch (e) {
                          debugPrint('UPDATE NAME ERROR: $e');
                        }

                        await updateProductStock(
                            productId: productId,
                            before: stock,
                            after: newStock);

                        onDone();
                        entry.remove();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text("Update",
                            style: GoogleFonts.poppins(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );

    overlayState.insert(entry);
  }

  void showSuccessToast(String message) {
    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => Positioned(
        top: 30,
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            height: 72,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: primary,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 3))
              ],
            ),
            child: Text(
              message,
              style: GoogleFonts.poppins(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    overlay?.insert(entry);
    Future.delayed(const Duration(seconds: 2), () => entry.remove());
  }

  void _openSidebar(BuildContext context) {
    final size = MediaQuery.of(context).size;

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.3),
      builder: (_) => Stack(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: size.width < 600 ? size.width * 0.8 : 350,
              height: size.height * 0.9,
              margin: const EdgeInsets.only(top: 40, bottom: 60),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(25),
                  bottomRight: Radius.circular(25),
                ),
                child: Material(
                  color: Colors.white,
                  child: SidebarMenu(selected: "stock"),
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
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final bool isSmall = screenWidth < 360;

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
                        icon:
                            Icon(Icons.menu, color: primary, size: isSmall ? 24 : 28),
                        onPressed: () => _openSidebar(context)),
                    const SizedBox(width: 10),
                    Text("Stock Product",
                        style: TextStyle(
                            fontSize: isSmall ? 18 : 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 20),
                    decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(10)),
                    child: IconButton(
                      icon: const Icon(Icons.history, color: Colors.white),
                      onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const HistoryPage())),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),

        body: Column(
          children: [
            const SizedBox(height: 22),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: Container(
                height: 56,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: const Color(0xFFAFACAC), width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Color(0xFFAFACAC)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: searchC,
                        onChanged: (v) =>
                            setState(() => searchQuery = v),
                        style: GoogleFonts.poppins(),
                        decoration: InputDecoration(
                          hintText: 'Search product...',
                          hintStyle: GoogleFonts.poppins(
                              color: const Color(0xFFAFACAC), fontSize: 16),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color:
                            const Color(0xFFD79771).withOpacity(0.40),
                        width: 1.4),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0xFFD79771)
                              .withOpacity(0.20),
                          blurRadius: 12,
                          offset: const Offset(0, 4))
                    ],
                  ),
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView(
                          children: products
                              .where((p) {
                                final q =
                                    searchQuery.trim().toLowerCase();
                                if (q.isEmpty) return true;
                                return p["name"]
                                    .toString()
                                    .toLowerCase()
                                    .contains(q);
                              })
                              .map((p) {
                                final int id = int.tryParse(p["id"].toString()) ?? 0;
                                final String name = p["name"] ?? "";
                                final int stock =
                                    int.tryParse(p["stock"].toString()) ?? 0;
                                final String? imageUrl =
                                    p["image_url"]?.toString();
                                final bool low = stock <= 10;

                                return Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 64,
                                          height: 64,
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            border: Border.all(
                                                color: const Color(
                                                        0xFFD79771)
                                                    .withOpacity(0.40),
                                                width: 1.4),
                                            boxShadow: [
                                              BoxShadow(
                                                  color: const Color(
                                                          0xFFD79771)
                                                      .withOpacity(0.30),
                                                  blurRadius: 8,
                                                  offset:
                                                      const Offset(0, 3))
                                            ],
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(14),
                                            child: (imageUrl != null &&
                                                    imageUrl.isNotEmpty)
                                                ? Image.network(imageUrl,
                                                    fit: BoxFit.cover,
                                                    errorBuilder:
                                                        (c, e, s) =>
                                                            Image.asset(
                                                                fallbackAsset))
                                                : Image.asset(
                                                    fallbackAsset),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(name,
                                                  style:
                                                      GoogleFonts.poppins(
                                                          fontSize: 17,
                                                          fontWeight:
                                                              FontWeight
                                                                  .w600)),
                                              const SizedBox(height: 4),
                                              Text('Stock : $stock',
                                                  style:
                                                      GoogleFonts.poppins(
                                                          color: Colors
                                                              .black54)),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets
                                                        .symmetric(
                                                            horizontal: 10,
                                                            vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: low
                                                      ? Colors.red.shade100
                                                      : Colors
                                                          .green.shade100,
                                                  borderRadius:
                                                      BorderRadius
                                                          .circular(10),
                                                ),
                                                child: Text(
                                                  low
                                                      ? "⚠️ Stock is running low"
                                                      : "Ready",
                                                  style:
                                                      GoogleFonts.poppins(
                                                    color: low
                                                        ? Colors.red
                                                        : Colors.green
                                                            .shade900,
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Builder(builder: (editCtx) {
                                          return IconButton(
                                            icon: Icon(Icons.edit,
                                                color: primary, size: 22),
                                            onPressed: () {
                                              final box =
                                                  editCtx.findRenderObject()
                                                      as RenderBox;
                                              final pos =
                                                  box.localToGlobal(
                                                      Offset.zero);

                                              showEditPopup(
                                                  context,
                                                  pos,
                                                  productId: id,
                                                  name: name,
                                                  stock: stock,
                                                  onDone: () {});
                                            },
                                          );
                                        }),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Divider(color: Colors.grey.shade300),
                                    const SizedBox(height: 10),
                                  ],
                                );
                              }).toList(),
                        ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  @override
  void dispose() {
    searchC.dispose();
    super.dispose();
  }
}
