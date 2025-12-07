import 'package:flutter/material.dart';
import '../../services/product_service.dart';

const Color primaryColor = Color(0xFF6E200D);

class AddProductDialog extends StatefulWidget {
  const AddProductDialog({super.key});

  @override
  State<AddProductDialog> createState() => _AddProductDialogState();
}

class _AddProductDialogState extends State<AddProductDialog> {
  final nameC = TextEditingController();
  final priceC = TextEditingController();
  final stockC = TextEditingController();
  final discountC = TextEditingController();

  int? selectedCategoryId;
  String? imageUrl;
  bool isLoading = false;

  final ProductService productService = ProductService();
  List<Map<String, dynamic>> categories = [];

  String? nameError;
  String? priceError;
  String? stockError;
  String? discountError;
  String? categoryError;
  String? imageError;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    final data = await productService.getCategories();
    setState(() {
      categories = data;
      if (categories.isNotEmpty) {
        selectedCategoryId = categories.first['categories_id'];
      }
    });
  }

  Future<void> pickImage() async {
    final url = await productService.pickAndUploadImage();
    if (url != null) {
      setState(() {
        imageUrl = url;
        imageError = null;
      });
    }
  }

  void _validateAndSave() {
    setState(() {
      nameError = nameC.text.trim().isEmpty
          ? "Name is required"
          : nameC.text.trim().length < 3
          ? "Min 3 characters"
          : null;

      priceError = priceC.text.trim().isEmpty
          ? "Price is required"
          : int.tryParse(priceC.text.trim()) == null
          ? "Must be a number"
          : null;

      stockError = stockC.text.trim().isEmpty
          ? "Stock is required"
          : int.tryParse(stockC.text.trim()) == null
          ? "Must be a number"
          : null;

      discountError = discountC.text.trim().isEmpty
          ? "Discount is required"
          : int.tryParse(discountC.text.trim()) == null
          ? "Must be a number"
          : null;

      categoryError = selectedCategoryId == null
          ? "Please select category"
          : null;
      imageError = imageUrl == null ? "Please choose an image" : null;
    });

    if (nameError != null ||
        priceError != null ||
        stockError != null ||
        discountError != null ||
        categoryError != null ||
        imageError != null) {
      return;
    }

    saveProduct();
  }

  Future<void> saveProduct() async {
    setState(() => isLoading = true);

    final price = int.parse(priceC.text.trim());
    final stock = int.parse(stockC.text.trim());
    final discount = int.parse(discountC.text.trim());

    final success = await productService.addProduct({
      "name": nameC.text.trim(),
      "price": price,
      "stock": stock,
      "discount": discount,
      "categories_id": selectedCategoryId,
      "image_url": imageUrl,
    });

    setState(() => isLoading = false);

    if (success && mounted) {
      Navigator.pop(context, true);
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to add product")));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenW = MediaQuery.of(context).size.width;
    final isTablet = screenW > 600;
    final isSmall = screenW < 360;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: isTablet ? 420 : double.maxFinite,
        padding: EdgeInsets.all(isTablet ? 22 : 18),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  "Add Product",
                  style: TextStyle(
                    fontSize: isTablet ? 30 : 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              _label("Name", isTablet),
              _input(nameC, isTablet: isTablet, errorText: nameError),
              if (nameError != null) _errorText(nameError!),
              const SizedBox(height: 12),

              _label("Price (Rp)", isTablet),
              _input(
                priceC,
                number: true,
                isTablet: isTablet,
                errorText: priceError,
              ),
              if (priceError != null) _errorText(priceError!),
              const SizedBox(height: 12),

              _label("Stock", isTablet),
              _input(
                stockC,
                number: true,
                isTablet: isTablet,
                errorText: stockError,
              ),
              if (stockError != null) _errorText(stockError!),
              const SizedBox(height: 12),

              _label("Discount (Rp)", isTablet),
              _input(
                discountC,
                number: true,
                isTablet: isTablet,
                errorText: discountError,
              ),
              if (discountError != null) _errorText(discountError!),
              const SizedBox(height: 12),

              LayoutBuilder(
                builder: (context, constraint) {
                  final isRow = constraint.maxWidth > 380;
                  return isRow
                      ? Row(
                          children: [
                            Expanded(
                              child: _categorySection(isTablet, categoryError),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _imageSection(isTablet, imageError),
                            ),
                          ],
                        )
                      : Column(
                          children: [
                            _categorySection(isTablet, categoryError),
                            const SizedBox(height: 14),
                            _imageSection(isTablet, imageError),
                          ],
                        );
                },
              ),

              const SizedBox(height: 25),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.pop(context),
                      style: _btn(isTablet),
                      child: Text(
                        "Cancel",
                        style: TextStyle(
                          fontSize: isTablet ? 20 : 18,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _validateAndSave,
                      style: _btn(isTablet),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              "Add",
                              style: TextStyle(
                                fontSize: isTablet ? 20 : 18,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _errorText(String text) => Padding(
    padding: const EdgeInsets.only(top: 6, left: 4),
    child: Text(text, style: const TextStyle(color: Colors.red, fontSize: 13)),
  );

  Widget _categorySection(bool isTablet, String? error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Category", isTablet),
        DropdownButtonFormField<int>(
          decoration: _dropdownDecoration(isTablet).copyWith(
            errorText: error,
            errorStyle: const TextStyle(color: Colors.red),
          ),
          value: selectedCategoryId,
          items: categories
              .map(
                (c) => DropdownMenuItem<int>(
                  value: c["categories_id"],
                  child: Text(c["name"]),
                ),
              )
              .toList(),
          onChanged: (v) => setState(() {
            selectedCategoryId = v;
            categoryError = null;
          }),
        ),
      ],
    );
  }

  Widget _imageSection(bool isTablet, String? error) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label("Image", isTablet),
        GestureDetector(
          onTap: pickImage,
          child: Container(
            height: isTablet ? 150 : 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: error != null ? Colors.red : Colors.black26,
                width: error != null ? 2 : 1,
              ),
              color: Colors.grey[100],
            ),
            child: imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(imageUrl!, fit: BoxFit.cover),
                  )
                : Center(
                    child: Text(
                      "Choose",
                      style: TextStyle(fontSize: isTablet ? 20 : 16),
                    ),
                  ),
          ),
        ),
        if (error != null) _errorText(error),
      ],
    );
  }

  Widget _label(String text, bool isTablet) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: isTablet ? 20 : 17,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _input(
    TextEditingController c, {
    bool number = false,
    required bool isTablet,
    String? errorText,
  }) {
    return Container(
      height: isTablet ? 50 : 42,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: errorText != null ? Colors.red : Colors.black26,
          width: errorText != null ? 2 : 1,
        ),
      ),
      child: TextField(
        controller: c,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        onChanged: (_) =>
            setState(() => errorText = null), // real-time clear error
        decoration: InputDecoration(
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
          errorText: null, // kita tampilkan manual di bawah
        ),
      ),
    );
  }

  InputDecoration _dropdownDecoration(bool isTablet) {
    return InputDecoration(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: isTablet ? 16 : 12,
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black26),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
    );
  }

  ButtonStyle _btn(bool isTablet) {
    return ButtonStyle(
      backgroundColor: MaterialStateProperty.all(primaryColor),
      padding: MaterialStateProperty.all(
        EdgeInsets.symmetric(vertical: isTablet ? 16 : 12),
      ),
      shape: MaterialStateProperty.all(
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    nameC.dispose();
    priceC.dispose();
    stockC.dispose();
    discountC.dispose();
    super.dispose();
  }
}
