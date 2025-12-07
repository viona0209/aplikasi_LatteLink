import 'package:flutter/material.dart';

const Color primaryColor = Color(0xFF6E200D);

class ProductCard extends StatelessWidget {
  final String name;
  final int price;
  final String? imageUrl;
  final String category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: primaryColor,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 14),

                Center(
                  child: Container(
                    height: 110,
                    width: 110,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF6E200D),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: ClipOval(
                      child: imageUrl != null && imageUrl!.isNotEmpty
                          ? Image.network(imageUrl!, fit: BoxFit.cover)
                          : _placeholderCircle(),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  "Rp $price",
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),

                const SizedBox(height: 14),
              ],
            ),

            Positioned(
              top: 6,
              right: 6,
              child: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') onEdit();
                  if (value == 'delete') onDelete();
                },
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFB05B3B), width: 2),
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    enabled: true,
                    value: 'edit',
                    child: Row(
                      children: const [
                        Icon(Icons.edit, size: 26, color: Colors.black),
                        SizedBox(width: 12),
                        Text(
                          "Edit",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const PopupMenuDivider(),

                  PopupMenuItem(
                    enabled: true,
                    value: 'delete',
                    child: Row(
                      children: const [
                        Icon(Icons.delete, size: 26, color: Colors.black),
                        SizedBox(width: 12),
                        Text(
                          "Delete",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                icon: const Icon(Icons.more_vert, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderCircle() {
    return Container(
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}
