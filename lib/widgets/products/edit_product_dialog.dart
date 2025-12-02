import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProductDialog extends StatefulWidget {
  final Map<String, dynamic> product;
  const EditProductDialog({super.key, required this.product});

  @override
 State<EditProductDialog> createState() => _EditProductDialogState();
}

class _EditProductDialogState extends State<EditProductDialog> {
  final supabase = Supabase.instance.client;

  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController discountController;

  String? imageUrl;
  XFile? pickedImage;
  Uint8List? previewBytes;

  int? categoryValue;
  List<Map<String, dynamic>> categories = [];
  bool isCategoryLoading = true;

  String? nameError;
  String? priceError;
  String? stockError;
  String? discountError;
  String? categoryError;
  String? imageError;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.product['name']);
    priceController = TextEditingController(text: widget.product['price'].toString());
    stockController = TextEditingController(text: widget.product['stock'].toString());
    discountController = TextEditingController(text: widget.product['discount'].toString());
    imageUrl = widget.product['image_url'];

    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final response = await supabase
          .from('categories')
          .select('categories_id, name')
          .order('name');

      categories = List<Map<String, dynamic>>.from(response);

      final existing = widget.product['categories']?[0]?['categories_id'] ??
                       widget.product['categories_id'];

      setState(() {
        categoryValue = existing is int ? existing : null;
        if (categoryValue == null && categories.isNotEmpty) {
          categoryValue = categories.first['categories_id'] as int;
        }
        isCategoryLoading = false;
      });
    } catch (e) {
      debugPrint("Category load error: $e");
      setState(() => isCategoryLoading = false);
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);

    if (picked != null) {
      final bytes = await picked.readAsBytes();
      setState(() {
        pickedImage = picked;
        previewBytes = bytes;
        imageError = null;
      });
    }
  }

  void _validateAndSave() {
    setState(() {
      nameError = nameController.text.trim().isEmpty
          ? "Name is required"
          : nameController.text.trim().length < 3
              ? "Min 3 characters"
              : null;

      priceError = priceController.text.trim().isEmpty
          ? "Price is required"
          : int.tryParse(priceController.text.trim()) == null
              ? "Must be a number"
              : null;

      stockError = stockController.text.trim().isEmpty
          ? "Stock is required"
          : int.tryParse(stockController.text.trim()) == null
              ? "Must be a number"
              : null;

      discountError = discountController.text.trim().isEmpty
          ? "Discount is required"
          : int.tryParse(discountController.text.trim()) == null
              ? "Must be a number"
              : null;

      categoryError = categoryValue == null ? "Please select category" : null;
      imageError = (imageUrl == null && pickedImage == null) ? "Image is required" : null;
    });

    if (nameError != null ||
        priceError != null ||
        stockError != null ||
        discountError != null ||
        categoryError != null ||
        imageError != null) {
      return;
    }

    _saveChanges();
  }

  Future<void> _saveChanges() async {
    try {
      String finalImageUrl = imageUrl ?? "";

      if (pickedImage != null) {
        final bytes = await pickedImage!.readAsBytes();
        final ext = pickedImage!.name.split('.').last;
        final fileName = "product_${DateTime.now().millisecondsSinceEpoch}.$ext";

        await supabase.storage.from('items').uploadBinary(
          fileName,
          bytes,
          fileOptions: FileOptions(contentType: "image/$ext"),
        );

        finalImageUrl = supabase.storage.from('items').getPublicUrl(fileName);
      }

      await supabase.from('products').update({
        'name': nameController.text.trim(),
        'price': int.parse(priceController.text.trim()),
        'stock': int.parse(stockController.text.trim()),
        'discount': int.parse(discountController.text.trim()),
        'categories_id': categoryValue,
        if (finalImageUrl.isNotEmpty) 'image_url': finalImageUrl,
      }).eq('id', widget.product['id']);

      // HANYA TUTUP DIALOG + RETURN TRUE — TIDAK ADA SNACKBAR APAPUN
      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      debugPrint("Update error: $e");
      // Kalau gagal → tetap di dialog, error muncul di field (validasi tetap jalan)
      // Tidak ada snackbar error juga
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isTablet = screenWidth > 600;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: isTablet ? 500 : double.maxFinite,
        padding: EdgeInsets.all(isTablet ? 24 : 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text("Edit Product",
                    style: TextStyle(fontSize: isTablet ? 26 : 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 20),

              // IMAGE PREVIEW
              Center(
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        width: isTablet ? 170 : 140,
                        height: isTablet ? 170 : 140,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          border: Border.all(
                            color: imageError != null ? Colors.red : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: previewBytes != null
                            ? Image.memory(previewBytes!, fit: BoxFit.cover)
                            : (imageUrl != null && imageUrl!.isNotEmpty
                                ? Image.network(imageUrl!, fit: BoxFit.cover)
                                : const Icon(Icons.image_not_supported, size: 60)),
                      ),
                    ),
                    if (imageError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(imageError!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                      ),
                    const SizedBox(height: 10),
                    OutlinedButton(
                      onPressed: pickImage,
                      child: Text("Change Image", style: TextStyle(fontSize: isTablet ? 18 : 16)),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _inputField(label: "Product Name", controller: nameController, isTablet: isTablet, error: nameError),
              _inputField(label: "Price", controller: priceController, type: TextInputType.number, isTablet: isTablet, error: priceError),
              _inputField(label: "Stock", controller: stockController, type: TextInputType.number, isTablet: isTablet, error: stockError),
              _inputField(label: "Discount (%)", controller: discountController, type: TextInputType.number, isTablet: isTablet, error: discountError),

              Text("Category", style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: categoryError != null ? Colors.red : Colors.black26,
                    width: categoryError != null ? 2 : 1,
                  ),
                ),
                child: isCategoryLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      )
                    : DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: categoryValue,
                          hint: const Text("Select category"),
                          isExpanded: true,
                          items: categories.map((cat) {
                            return DropdownMenuItem<int>(
                              value: cat['categories_id'] as int,
                              child: Text(cat['name']),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() {
                            categoryValue = v;
                            categoryError = null;
                          }),
                        ),
                      ),
              ),
              if (categoryError != null)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4),
                  child: Text(categoryError!, style: const TextStyle(color: Colors.red, fontSize: 14)),
                ),

              const SizedBox(height: 26),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: isTablet ? 18 : 14),
                    backgroundColor: const Color(0xFF6E200D),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _validateAndSave,
                  child: const Text("Save Changes",
                      style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField({
    required String label,
    required TextEditingController controller,
    TextInputType? type,
    required bool isTablet,
    String? error,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: isTablet ? 18 : 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: type,
            onChanged: (_) => setState(() => error = null),
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: error != null ? Colors.red : Colors.black26),
              ),
              focusedBorder: const OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(12)),
                borderSide: BorderSide(color: Colors.black, width: 2),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: isTablet ? 18 : 14),
            ),
          ),
          if (error != null)
            Padding(
              padding: const EdgeInsets.only(top: 6, left: 4),
              child: Text(error!, style: const TextStyle(color: Colors.red, fontSize: 14)),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    priceController.dispose();
    stockController.dispose();
    discountController.dispose();
    super.dispose();
  }
}