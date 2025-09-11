import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/common_widgets/custom_widget.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductDetailPage extends StatefulWidget {
  static const routeName = "/product_detail";
  const ProductDetailPage({super.key, required this.product});
  final ProductModel product;
  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentIndex = 0;

  // size + color + quantity state
  String selectedSize = "M";
  Color selectedColor = Colors.red;
  int quantity = 1;

  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.black
  ];

  @override
  Widget build(BuildContext context) {
    final productSize = widget.product.productSize;
    final List<String> sizes =
        productSize!.map((element) => element.size!.sizeName).toList() ?? [];
    final List<String> images = widget.product.imageUrls ?? [];
    final originalPrice = widget.product.priceHistoryModel?.isNotEmpty == true
        ? (widget.product.priceHistoryModel!.first.price ?? 0).toDouble()
        : 0.0;
    final discount = widget.product.discounts?.isNotEmpty == true
        ? (widget.product.discounts!.first.discountPercentage ?? 0).toDouble()
        : 0.0;
    final discountedPrice = originalPrice * (1 - (discount / 100));
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Carousel
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 400,
                    enlargeCenterPage: true,
                    viewportFraction: 1,
                    autoPlay: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                  ),
                  items: images.map((imagePath) {
                    return Image.network(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    );
                  }).toList(),
                ),
                // Dots indicator
                if (images.isNotEmpty)
                  Positioned(
                    bottom: 8,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: images.asMap().entries.map((entry) {
                        return Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _currentIndex == entry.key
                                ? Colors.blueAccent
                                : Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 20),

            // Product details
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product name
                  Text(
                    widget.product.name ?? "Tên sản phẩm",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Brand name
                  if (widget.product.brand?.brandName != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          const Icon(Icons.verified,
                              size: 16, color: Colors.blue),
                          const SizedBox(width: 4),
                          Text(
                            widget.product.brand!.brandName!,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // SKU
                  if (widget.product.sku != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        "Mã SP: ${widget.product.sku}",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),

                  // Product description
                  Text(
                    widget.product.description ?? "Không có mô tả",
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),

                  // Rating
                  Row(
                    children: [
                      RatingStars(rating: widget.product.averageRating ?? 0),
                      const SizedBox(width: 8),
                      Text(
                        "(${widget.product.totalRatings ?? 0} đánh giá)",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price section
                  Row(
                    children: [
                      if (discount > 0) ...[
                        Text(
                          currencyFormatter.format(discountedPrice),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          currencyFormatter.format(originalPrice),
                          style: TextStyle(
                            fontSize: 16,
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            "-${discount.toInt()}%",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ] else ...[
                        Text(
                          currencyFormatter.format(originalPrice),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Size selection
                  Text(
                    "Chọn size",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 10,
                    children: sizes.map((size) {
                      final isSelected = selectedSize == size;
                      return ChoiceChip(
                        label: Text(size),
                        selected: isSelected,
                        onSelected: (_) {
                          setState(() {
                            selectedSize = size;
                          });
                        },
                        selectedColor: Theme.of(context).colorScheme.secondary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black,
                        ),
                      );
                    }).toList(),
                  ),

                  // Color selection

                  widget.product.variants!.length != 0
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              "Chọn màu",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              children: colors.map((color) {
                                final isSelected = selectedColor == color;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      selectedColor = color;
                                    });
                                  },
                                  child: CircleAvatar(
                                    radius: isSelected ? 22 : 20,
                                    backgroundColor: color,
                                    child: isSelected
                                        ? const Icon(Icons.check,
                                            color: Colors.white)
                                        : null,
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        )
                      : const SizedBox(height: 20),
                  // Quantity selection
                  Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Số lượng",
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              onPressed: () {
                                if (quantity > 1) {
                                  setState(() {
                                    quantity--;
                                  });
                                }
                              },
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              "$quantity",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                setState(() {
                                  quantity++;
                                });
                              },
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                      ]),

                  const SizedBox(height: 20),

                  // Product specifications
                  Text(
                    "Thông tin chi tiết",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.product.brand!.brandName != null)
                          _buildSpecRow(
                              "Thương hiệu", widget.product.brand!.brandName),
                        if (widget.product.originCountry != null)
                          _buildSpecRow(
                              "Xuất xứ", widget.product.originCountry!),
                        if (widget.product.material != null)
                          _buildSpecRow("Chất liệu", widget.product.material!),
                        if (widget.product.color != null)
                          _buildSpecRow("Màu sắc", widget.product.color!),
                        if (widget.product.features != null)
                          _buildSpecRow("Kiểu dáng",
                              "${widget.product.features?["style"] ?? 'N/A'}, ${widget.product.features?["pocket"] ?? 'N/A'}"),
                        if (widget.product.weight != null)
                          _buildSpecRow(
                              "Trọng lượng", "${widget.product.weight}kg"),
                        if (widget.product.dimensions != null)
                          _buildSpecRow(
                              "Kích thước",
                              "${widget.product.dimensions?["width_cm"] ?? 'N/A'} cm x "
                                  "${widget.product.dimensions?["height_cm"] ?? 'N/A'} cm x "
                                  "${widget.product.dimensions?["length_cm"] ?? 'N/A'} cm"),
                        if (widget.product.warrantyMonths != null)
                          _buildSpecRow("Bảo hành",
                              "${widget.product.warrantyMonths} tháng"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Care instructions
                  if (widget.product.careInstructions != null) ...[
                    Text(
                      "Hướng dẫn bảo quản",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Text(
                        widget.product.careInstructions!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Tags
                  if (widget.product.tags?.isNotEmpty == true) ...[
                    Text(
                      "Tags",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: widget.product.tags!.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Theme.of(context)
                                .colorScheme
                                .primary
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            "#$tag",
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Return Policy Section (keep existing)
                  Text(
                    "Chính sách đổi trả",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green[200]!),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("✔ Đổi trả miễn phí trong 7 ngày"),
                        SizedBox(height: 6),
                        Text("✔ Hoàn tiền nếu sản phẩm lỗi"),
                        SizedBox(height: 6),
                        Text("✔ Hỗ trợ đổi size nếu không vừa"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 40, thickness: 1),

            // Customer Reviews Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Đánh giá của khách hàng",
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Điều hướng sang trang tất cả review
                        },
                        child: const Text("Xem tất cả"),
                      )
                    ],
                  ),

                  // Rating summary
                  if (widget.product.totalRatings != null &&
                      widget.product.totalRatings! > 0) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              Text(
                                "${widget.product.averageRating ?? 0}",
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              RatingStars(
                                  rating: widget.product.averageRating ?? 0),
                              Text(
                                "${widget.product.totalRatings} đánh giá",
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          // Rating distribution could be added here if needed
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Sample reviews (keep existing)
                  _buildReviewItem(
                    avatar: "A",
                    name: "Nguyễn Văn A",
                    rating: 5,
                    comment: "Sản phẩm chất lượng, giao hàng nhanh.",
                  ),
                  _buildReviewItem(
                    avatar: "B",
                    name: "Trần Thị B",
                    rating: 4,
                    comment: "Đẹp nhưng size hơi nhỏ, nên chọn lớn hơn 1 size.",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                ),
                onPressed: () {
                  debugPrint(
                      "Thêm vào giỏ: size=$selectedSize, màu=$selectedColor, số lượng=$quantity");
                },
                child: const Text(
                  "Thêm vào giỏ hàng",
                  style: TextStyle(fontSize: 18),
                ),
              ),
              SizedBox(
                width: 4,
              ),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    debugPrint(
                        "Mua ngay: size=$selectedSize, màu=$selectedColor, số lượng=$quantity");
                  },
                  child: const Text(
                    "Mua ngay",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpecRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  String _formatFeatures(Map<String, dynamic> features) {
    List<String> featuresList = [];

    features.forEach((key, value) {
      if (value != null) {
        String formattedKey = _formatKey(key);
        featuresList.add("$formattedKey: $value");
      }
    });

    return featuresList.join(", ");
  }

  String _formatDimensions(Map<String, dynamic> dimensions) {
    double? width = dimensions['width_cm']?.toDouble();
    double? height = dimensions['height_cm']?.toDouble();
    double? length = dimensions['length_cm']?.toDouble();

    List<String> dimensionParts = [];

    if (width != null) dimensionParts.add("R: ${width}cm");
    if (height != null) dimensionParts.add("C: ${height}cm");
    if (length != null) dimensionParts.add("D: ${length}cm");

    return dimensionParts.join(" x ");
  }

  String _formatKey(String key) {
    switch (key.toLowerCase()) {
      case 'style':
        return 'Phong cách';
      case 'pocket':
        return 'Túi';
      case 'sleeve':
        return 'Tay áo';
      case 'collar':
        return 'Cổ áo';
      case 'material':
        return 'Chất liệu';
      case 'pattern':
        return 'Họa tiết';
      case 'fit':
        return 'Form dáng';
      default:
        return key
            .replaceAll('_', ' ')
            .toLowerCase()
            .split(' ')
            .map((word) => word.isNotEmpty
                ? word[0].toUpperCase() + word.substring(1)
                : '')
            .join(' ');
    }
  }

  Widget _buildReviewItem({
    required String avatar,
    required String name,
    required double rating,
    required String comment,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            child: Text(avatar),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                RatingStars(rating: rating),
                const SizedBox(height: 4),
                Text(comment),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
