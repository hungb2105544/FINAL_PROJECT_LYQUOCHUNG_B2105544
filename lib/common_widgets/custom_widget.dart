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
