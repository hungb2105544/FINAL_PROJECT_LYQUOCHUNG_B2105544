import 'package:cached_network_image/cached_network_image.dart';
import 'package:ecommerce_app/common_widgets/custom_widget.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/presentation/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product});
  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final double baseFont = screenWidth * 0.04;
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    final hasPriceHistory = product.priceHistoryModel?.isNotEmpty ?? false;
    final hasDiscounts = product.discounts?.isNotEmpty ?? false;

    final originalPrice = hasPriceHistory
        ? (product.priceHistoryModel!.first.price ?? 0).toDouble()
        : 0.0;

    final discount = hasDiscounts
        ? (product.discounts!.first.discountPercentage ?? 0).toDouble()
        : 0.0;

    final discountedPrice = originalPrice * (1 - (discount / 100));
    final hasDiscount = hasDiscounts && discount > 0;

    final imageUrl = (product.imageUrls?.isNotEmpty ?? false)
        ? product.imageUrls!.first.toString()
        : '';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailPage(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
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
                  // 🖼 Ảnh sản phẩm có cache + shimmer
                  AspectRatio(
                    aspectRatio: 1,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          color: Colors.white,
                        ),
                      ),
                      errorWidget: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),

                  // 🏷 Tên sản phẩm
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      product.name,
                      style: TextStyle(
                        fontSize: baseFont,
                        fontWeight: FontWeight.w500,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // 💰 Giá
                  if (hasDiscount) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        currencyFormatter.format(discountedPrice),
                        style: TextStyle(
                          fontSize: baseFont * 1.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ] else if (hasPriceHistory)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        currencyFormatter.format(originalPrice),
                        style: TextStyle(
                          fontSize: baseFont * 1.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                  // ⭐ Rating
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RatingStars(
                      rating: product.averageRating,
                      size: baseFont,
                    ),
                  ),
                ],
              ),

              // 🔖 Badge giảm giá
              if (hasDiscount)
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
                        '-${discount.toInt()}%',
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
      ),
    );
  }
}
