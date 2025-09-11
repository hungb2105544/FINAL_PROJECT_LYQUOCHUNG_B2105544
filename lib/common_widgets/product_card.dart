import 'package:ecommerce_app/common_widgets/custom_widget.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/presentation/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double baseFont = screenWidth * 0.04;
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final originalPrice =
        (product.priceHistoryModel!.first.price ?? 0).toDouble();
    final discount =
        (product.discounts!.first.discountPercentage ?? 0).toDouble();
    final discountedPrice =
        originalPrice * (1 - (discount / 100)); // nếu discount = 0.3

    return GestureDetector(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProductDetailPage(product: this.product)));
      },
      child: Container(
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

                  product.discounts!.first.discountPercentage != 0
                      ? Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                currencyFormatter.format(originalPrice),
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  fontStyle: FontStyle.italic,
                                  fontSize: baseFont * 1.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ), // Giá
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                currencyFormatter.format(discountedPrice),
                                style: TextStyle(
                                  fontSize: baseFont * 1.05,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        )
                      : Column(),

                  // Rating
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RatingStars(
                        rating: product.averageRating, size: baseFont),
                  ),
                ],
              ),
              // Giảm giá
              Visibility(
                visible: product.discounts!.first.discountPercentage != 0
                    ? true
                    : false,
                child: Positioned(
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
                        "${product.discounts!.first.discountPercentage}%",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: baseFont * 0.8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
