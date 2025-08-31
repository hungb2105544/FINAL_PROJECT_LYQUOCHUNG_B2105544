import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/common_widgets/custom_widget.dart';
import 'package:flutter/material.dart';

class ProductDetailPage extends StatefulWidget {
  const ProductDetailPage({super.key});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  int _currentIndex = 0;

  final List<String> images = [
    'assets/images/26.png',
    'assets/images/27.png',
    'assets/images/28.png',
    'assets/images/29.png',
  ];

  // size + color + quantity state
  String selectedSize = "M";
  Color selectedColor = Colors.red;
  int quantity = 1;

  final List<String> sizes = ["S", "M", "L", "XL"];
  final List<Color> colors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.black
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    return Image.asset(
                      imagePath,
                      width: double.infinity,
                      fit: BoxFit.fill,
                    );
                  }).toList(),
                ),
                // Dots indicator
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
                  const Text(
                    "Tên sản phẩm",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Mô tả sản phẩm chi tiết ở đây. Có thể bao gồm chất liệu, "
                    "kiểu dáng, hướng dẫn sử dụng, v.v...",
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                  const RatingStars(rating: 5),
                  const SizedBox(height: 8),
                  const Text(
                    "Giá: 499,000đ",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
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

                  const SizedBox(height: 20),

                  // Color selection
                  Text(
                    "Chọn màu",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                              ? const Icon(Icons.check, color: Colors.white)
                              : null,
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

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
                        const SizedBox(height: 8),
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

                  const SizedBox(height: 10),
                  Text(
                    "Thông tin chi tiết",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "• Thương hiệu: Uniqlo",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 6),
                        Text(
                          "• Xuất xứ: Việt Nam",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 6),
                        Text(
                          "• Chất liệu: 100% Cotton",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 6),
                        Text(
                          "• Kiểu dáng: Regular Fit",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        SizedBox(height: 6),
                        Text(
                          "• Mã sản phẩm: SKU123456",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  // Return Policy Section
                  Text(
                    "Chính sách đổi trả",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
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
                  const SizedBox(height: 12),
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
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
              const SizedBox(width: 16),
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
