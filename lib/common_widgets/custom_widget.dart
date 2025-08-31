import 'dart:async';

import 'package:flutter/material.dart';

// Widget đánh giá sao
class RatingStars extends StatelessWidget {
  final double rating;
  final int starCount;
  final double size;
  final Color filledColor;
  final Color unfilledColor;

  const RatingStars({
    super.key,
    required this.rating,
    this.starCount = 5,
    this.size = 24,
    this.filledColor = Colors.amber,
    this.unfilledColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(starCount, (index) {
        if (index < rating.floor()) {
          // Sao đầy
          return Icon(Icons.star, color: filledColor, size: size);
        } else if (index < rating) {
          // Sao nửa
          return Icon(Icons.star_half, color: filledColor, size: size);
        } else {
          // Sao rỗng
          return Icon(Icons.star_border, color: unfilledColor, size: size);
        }
      }),
    );
  }
}

// Widget thẻ sản phẩm
class ProductCard extends StatelessWidget {
  const ProductCard({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double baseFont = screenWidth * 0.04;
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
                  child: Image.asset(
                    "assets/images/26.png",
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
                    "Áo thun FIDE Jelly unisex form rộng nam nữ local brand cổ tròn oversize- AT210",
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
                      rating: 5, size: baseFont), // 👈 tuỳ chỉnh size
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

class CategoryCard extends StatelessWidget {
  const CategoryCard({
    super.key,
    required this.categoryName,
    required this.imagePath,
  });

  final String categoryName;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // 👇 Card co giãn nhưng không vượt quá 140px
    final cardWidth = (screenWidth * 0.22).clamp(90.0, 140.0);
    final imageSize = cardWidth * 0.6;

    // 👇 font chữ có giới hạn
    final fontSize = (screenWidth * 0.035).clamp(12.0, 16.0);

    return SizedBox(
      width: cardWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                imagePath,
                height: imageSize,
                width: imageSize,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: imageSize,
                  width: imageSize,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image,
                      size: 40, color: Colors.grey),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            categoryName,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
