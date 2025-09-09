import 'package:ecommerce_app/common_widgets/custom_widget.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double baseFont = screenWidth * 0.04;
    print("${product.toString()}");
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hình sản phẩm tỉ lệ vuông
                AspectRatio(
                  aspectRatio: 1,
                  child: Image.network(
                    (product.imageUrls as List).first.toString(),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image,
                          size: 50, color: Colors.grey),
                    ),
                  ),
                ),
                // Tên sản phẩm
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    product.name,
                    style: TextStyle(
                        fontSize: baseFont,
                        fontWeight: FontWeight.w500,
                        height: 1.2),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Giá
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "100.000 đ",
                    style: TextStyle(
                      fontSize: baseFont * 1.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                // Rating
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RatingStars(
                      rating: product.averageRating,
                      size: baseFont), // 👈 tuỳ chỉnh size
                ),
              ],
            ),
            // Giảm giá
            Positioned(
              right: 0,
              child: Container(
                height: screenWidth * 0.07,
                width: screenWidth * 0.14,
                decoration: const BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(12),
                  ),
                ),
                child: Center(
                  child: Text(
                    "-30%",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: baseFont * 0.8,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
