import 'package:flutter/material.dart';

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
              child: _buildImage(imageSize),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            categoryName,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w500),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildImage(double imageSize) {
    return Image.network(
      imagePath,
      height: imageSize,
      width: imageSize,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          height: imageSize,
          width: imageSize,
          color: Colors.grey[200],
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) =>
          _buildErrorWidget(imageSize),
    );
  }

  Widget _buildErrorWidget(double imageSize) {
    return Container(
      height: imageSize,
      width: imageSize,
      color: Colors.grey[200],
      child: const Icon(
        Icons.category_outlined,
        size: 40,
        color: Colors.grey,
      ),
    );
  }
}
