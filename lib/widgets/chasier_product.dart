import 'package:flutter/material.dart';
import '../models/product_model.dart';

class ChasierProduct extends StatefulWidget {
  final ProductModel product;
  final VoidCallback onAddToCart;

  const ChasierProduct({
    super.key,
    required this.product,
    required this.onAddToCart,
  });

  @override
  State<ChasierProduct> createState() => _ChasierProductState();
}

class _ChasierProductState extends State<ChasierProduct> {
  int qty = 0;

  @override
  Widget build(BuildContext context) {
    final imageUrl = widget.product.imageUrl;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6E200D),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        children: [
          SizedBox(
            height: 120,
            child: imageUrl.startsWith("http")
                ? Image.network(imageUrl, fit: BoxFit.contain)
                : Image.asset(imageUrl, fit: BoxFit.contain),
          ),

          const SizedBox(height: 5),

          Text(
            widget.product.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 5),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Rp.${widget.product.price}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (qty > 0) setState(() => qty--);
                      },
                      child: const Icon(
                        Icons.remove,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      qty.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 6),
                    GestureDetector(
                      onTap: () => setState(() => qty++),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),
          GestureDetector(
            onTap: widget.onAddToCart,
            child: Container(
              height: 32,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
