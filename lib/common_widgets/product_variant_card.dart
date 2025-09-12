import 'package:flutter/material.dart';

class ProductVariantCard extends StatelessWidget {
  const ProductVariantCard({
    super.key,
    required this.color,
    required this.imageUrl,
  });

  final String color;
  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12), // bo góc
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // bóng mờ
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // khung ảnh
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            child: AspectRatio(
              aspectRatio: 1, // giữ ảnh vuông
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 48),
              ),
            ),
          ),
          // tên màu
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              color,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
