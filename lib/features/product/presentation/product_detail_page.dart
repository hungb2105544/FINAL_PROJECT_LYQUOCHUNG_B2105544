// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:ecommerce_app/common_widgets/custom_widget.dart';
// import 'package:ecommerce_app/common_widgets/product_variant_card.dart';
// import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
// import 'package:ecommerce_app/features/product/data/models/branch_stock_model.dart';
// import 'package:ecommerce_app/features/product/data/models/product_model.dart';
// import 'package:ecommerce_app/features/product/data/models/product_variant_model.dart';
// import 'package:ecommerce_app/features/product/widget/custom_widget.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class ProductDetailPage extends StatefulWidget {
//   static const routeName = "/product_detail";
//   const ProductDetailPage({super.key, required this.product});
//   final ProductModel product;
//   @override
//   State<ProductDetailPage> createState() => _ProductDetailPageState();
// }

// class _ProductDetailPageState extends State<ProductDetailPage> {
//   int _currentIndex = 0;
//   String selectedSize = "M";
//   SimplifiedVariantModel? selectedColor;
//   int quantity = 1;

//   BranchStockModel? nearestStock;
//   bool isLoadingStock = false;
//   String? stockError;

//   @override
//   void initState() {
//     super.initState();
//     _loadNearestStock();
//   }

//   Future<void> _loadNearestStock() async {
//     final userId = SupabaseConfig.client.auth.currentUser?.id;
//     if (userId == null) return;

//     setState(() {
//       isLoadingStock = true;
//       stockError = null;
//     });

//     try {
//       final stock = await _fetchNearestStock(
//           userId, widget.product.id!, selectedColor?.variantId);

//       setState(() {
//         nearestStock = stock;
//         isLoadingStock = false;
//       });
//     } catch (e) {
//       setState(() {
//         stockError = e.toString();
//         isLoadingStock = false;
//       });
//     }
//   }

//   Future<BranchStockModel?> _fetchNearestStock(
//       String userId, int productId, int? variantId) async {
//     try {
//       final response =
//           await SupabaseConfig.client.rpc('get_nearest_branch_stock', params: {
//         'user_id': userId,
//         'product_id': productId,
//         if (variantId != null) 'variant_id': variantId,
//       });

//       if (response != null && response.isNotEmpty) {
//         return BranchStockModel.fromJson(response.first);
//       }
//       return null;
//     } catch (e) {
//       debugPrint('Error fetching nearest stock: $e');
//       rethrow;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final productSize = widget.product.productSize;
//     final List<String> sizes =
//         productSize!.map((element) => element.size!.sizeName).toList() ?? [];
//     final List<String> images = widget.product.imageUrls ?? [];
//     final originalPrice = widget.product.priceHistoryModel?.isNotEmpty == true
//         ? (widget.product.priceHistoryModel!.first.price ?? 0).toDouble()
//         : 0.0;
//     final discount = widget.product.discounts?.isNotEmpty == true
//         ? (widget.product.discounts!.first.discountPercentage ?? 0).toDouble()
//         : 0.0;
//     final discountedPrice = originalPrice * (1 - (discount / 100));
//     final currencyFormatter =
//         NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back, color: Theme.of(context).primaryColor),
//           onPressed: () => Navigator.pop(context),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             // Carousel
//             Stack(
//               alignment: Alignment.bottomCenter,
//               children: [
//                 CarouselSlider(
//                   options: CarouselOptions(
//                     height: 400,
//                     enlargeCenterPage: true,
//                     viewportFraction: 1,
//                     autoPlay: true,
//                     onPageChanged: (index, reason) {
//                       setState(() {
//                         _currentIndex = index;
//                       });
//                     },
//                   ),
//                   items: images.map((imagePath) {
//                     return Image.network(
//                       imagePath,
//                       width: double.infinity,
//                       fit: BoxFit.fill,
//                     );
//                   }).toList(),
//                 ),
//                 // Dots indicator
//                 if (images.isNotEmpty)
//                   Positioned(
//                     bottom: 8,
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: images.asMap().entries.map((entry) {
//                         return Container(
//                           width: 8,
//                           height: 8,
//                           margin: const EdgeInsets.symmetric(horizontal: 3),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: _currentIndex == entry.key
//                                 ? Colors.blueAccent
//                                 : Colors.grey,
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                   ),
//               ],
//             ),

//             const SizedBox(height: 20),

//             // Product details
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Product name
//                   Text(
//                     widget.product.name ?? "Tên sản phẩm",
//                     style: const TextStyle(
//                       fontSize: 22,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 8),

//                   // Brand name
//                   if (widget.product.brand?.brandName != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8.0),
//                       child: Row(
//                         children: [
//                           const Icon(Icons.verified,
//                               size: 16, color: Colors.blue),
//                           const SizedBox(width: 4),
//                           Text(
//                             widget.product.brand!.brandName!,
//                             style: const TextStyle(
//                               fontSize: 14,
//                               color: Colors.blue,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                   // SKU
//                   if (widget.product.sku != null)
//                     Padding(
//                       padding: const EdgeInsets.only(bottom: 8.0),
//                       child: Text(
//                         "Mã SP: ${widget.product.sku}",
//                         style: TextStyle(
//                           fontSize: 14,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ),

//                   // Stock Info - THÊM MỚI
//                   const SizedBox(height: 8),
//                   StockInfoCard(
//                     isLoading: isLoadingStock,
//                     error: stockError,
//                     stock: nearestStock,
//                   ),
//                   const SizedBox(height: 16),

//                   // Product description
//                   Text(
//                     widget.product.description ?? "Không có mô tả",
//                     style: const TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 16),

//                   // Rating
//                   Row(
//                     children: [
//                       RatingStars(rating: widget.product.averageRating ?? 0),
//                       const SizedBox(width: 8),
//                       Text(
//                         "(${widget.product.totalRatings ?? 0} đánh giá)",
//                         style: TextStyle(
//                           color: Colors.grey[600],
//                           fontSize: 14,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const SizedBox(height: 8),

//                   // Price section
//                   Row(
//                     children: [
//                       if (discount > 0) ...[
//                         Text(
//                           currencyFormatter.format(discountedPrice),
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Text(
//                           currencyFormatter.format(originalPrice),
//                           style: TextStyle(
//                             fontSize: 16,
//                             decoration: TextDecoration.lineThrough,
//                             color: Colors.grey[600],
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 6, vertical: 2),
//                           decoration: BoxDecoration(
//                             color: Colors.red,
//                             borderRadius: BorderRadius.circular(4),
//                           ),
//                           child: Text(
//                             "-${discount.toInt()}%",
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontSize: 12,
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                       ] else ...[
//                         Text(
//                           currencyFormatter.format(originalPrice),
//                           style: const TextStyle(
//                             fontSize: 20,
//                             fontWeight: FontWeight.bold,
//                             color: Colors.red,
//                           ),
//                         ),
//                       ],
//                     ],
//                   ),

//                   const SizedBox(height: 20),

//                   // Size selection
//                   Text(
//                     "Chọn size",
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const SizedBox(height: 8),
//                   Wrap(
//                     spacing: 10,
//                     children: sizes.map((size) {
//                       final isSelected = selectedSize == size;
//                       return ChoiceChip(
//                         label: Text(size),
//                         selected: isSelected,
//                         onSelected: (_) {
//                           setState(() {
//                             selectedSize = size;
//                           });
//                         },
//                         selectedColor: Theme.of(context).colorScheme.secondary,
//                         labelStyle: TextStyle(
//                           color: isSelected ? Colors.white : Colors.black,
//                         ),
//                       );
//                     }).toList(),
//                   ),

//                   // Color selection
//                   widget.product.simplifiedVariants!.isNotEmpty
//                       ? Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             const SizedBox(height: 20),
//                             Text(
//                               "Các mẫu",
//                               style: Theme.of(context)
//                                   .textTheme
//                                   .titleMedium
//                                   ?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                             ),
//                             const SizedBox(height: 8),
//                             SizedBox(
//                               child: SingleChildScrollView(
//                                 scrollDirection: Axis.horizontal,
//                                 child: Row(
//                                   children: widget.product.simplifiedVariants!
//                                       .map((variant) {
//                                     final isSelected = selectedColor == variant;
//                                     return GestureDetector(
//                                       onTap: () {
//                                         setState(() {
//                                           selectedColor = variant;
//                                         });
//                                         // Reload stock khi đổi variant
//                                         _loadNearestStock();
//                                       },
//                                       child: Container(
//                                         width:
//                                             MediaQuery.of(context).size.width *
//                                                 0.3,
//                                         margin:
//                                             const EdgeInsets.only(right: 12),
//                                         decoration: BoxDecoration(
//                                           border: Border.all(
//                                             color: isSelected
//                                                 ? Theme.of(context)
//                                                     .colorScheme
//                                                     .secondary
//                                                 : Theme.of(context)
//                                                     .colorScheme
//                                                     .primary,
//                                             width: 2,
//                                           ),
//                                           boxShadow: isSelected
//                                               ? [
//                                                   BoxShadow(
//                                                     color: Theme.of(context)
//                                                         .colorScheme
//                                                         .secondary
//                                                         .withOpacity(0.5),
//                                                     blurRadius: 8,
//                                                     spreadRadius: 2,
//                                                     offset: const Offset(0, 4),
//                                                   ),
//                                                 ]
//                                               : [],
//                                           borderRadius:
//                                               BorderRadius.circular(12),
//                                         ),
//                                         child: ProductVariantCard(
//                                           color: variant.color,
//                                           imageUrl: variant.imageUrl.toString(),
//                                         ),
//                                       ),
//                                     );
//                                   }).toList(),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         )
//                       : const SizedBox(height: 10),

//                   const SizedBox(height: 10),

//                   // Quantity selection
//                   Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           "Số lượng",
//                           style:
//                               Theme.of(context).textTheme.titleMedium?.copyWith(
//                                     fontWeight: FontWeight.bold,
//                                   ),
//                         ),
//                         Row(
//                           children: [
//                             IconButton(
//                               onPressed: () {
//                                 if (quantity > 1) {
//                                   setState(() {
//                                     quantity--;
//                                   });
//                                 }
//                               },
//                               icon: const Icon(Icons.remove_circle_outline),
//                             ),
//                             Text(
//                               "$quantity",
//                               style: const TextStyle(
//                                 fontSize: 18,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                             IconButton(
//                               onPressed: () {
//                                 // Giới hạn số lượng theo stock
//                                 final maxQuantity =
//                                     nearestStock?.availableStock ?? 999;
//                                 if (quantity < maxQuantity) {
//                                   setState(() {
//                                     quantity++;
//                                   });
//                                 } else {
//                                   ScaffoldMessenger.of(context).showSnackBar(
//                                     SnackBar(
//                                       content:
//                                           Text("Chỉ còn $maxQuantity sản phẩm"),
//                                       backgroundColor: Colors.orange,
//                                     ),
//                                   );
//                                 }
//                               },
//                               icon: const Icon(Icons.add_circle_outline),
//                             ),
//                           ],
//                         ),
//                       ]),

//                   const SizedBox(height: 20),

//                   // Product specifications
//                   Text(
//                     "Thông tin chi tiết",
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.grey[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.grey[300]!),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         if (widget.product.brand!.brandName != null)
//                           SpecRow(
//                               label: "Thương hiệu",
//                               value: widget.product.brand!.brandName!),
//                         if (widget.product.originCountry != null)
//                           SpecRow(
//                               label: "Xuất xứ",
//                               value: widget.product.originCountry!),
//                         if (widget.product.material != null)
//                           SpecRow(
//                               label: "Chất liệu",
//                               value: widget.product.material!),
//                         if (widget.product.color != null)
//                           SpecRow(
//                               label: "Màu sắc", value: widget.product.color!),
//                         if (widget.product.features != null)
//                           SpecRow(
//                               label: "Kiểu dáng",
//                               value:
//                                   "${widget.product.features?["style"] ?? 'N/A'}, ${widget.product.features?["pocket"] ?? 'N/A'}"),
//                         if (widget.product.weight != null)
//                           SpecRow(
//                               label: "Trọng lượng",
//                               value: "${widget.product.weight}kg"),
//                         if (widget.product.dimensions != null)
//                           SpecRow(
//                               label: "Kích thước",
//                               value:
//                                   "${widget.product.dimensions?["width_cm"] ?? 'N/A'} cm x "
//                                   "${widget.product.dimensions?["height_cm"] ?? 'N/A'} cm x "
//                                   "${widget.product.dimensions?["length_cm"] ?? 'N/A'} cm"),
//                         if (widget.product.warrantyMonths != null)
//                           SpecRow(
//                               label: "Bảo hành",
//                               value: "${widget.product.warrantyMonths} tháng"),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 20),

//                   // Care instructions
//                   if (widget.product.careInstructions != null) ...[
//                     Text(
//                       "Hướng dẫn bảo quản",
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     const SizedBox(height: 8),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(16.0),
//                       decoration: BoxDecoration(
//                         color: Colors.blue[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.blue[200]!),
//                       ),
//                       child: Text(
//                         widget.product.careInstructions!,
//                         style: const TextStyle(fontSize: 14),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],

//                   // Tags
//                   if (widget.product.tags?.isNotEmpty == true) ...[
//                     Text(
//                       "Tags",
//                       style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                             fontWeight: FontWeight.bold,
//                           ),
//                     ),
//                     const SizedBox(height: 8),
//                     Wrap(
//                       spacing: 8,
//                       runSpacing: 4,
//                       children: widget.product.tags!.map((tag) {
//                         return Container(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 12, vertical: 6),
//                           decoration: BoxDecoration(
//                             color: Theme.of(context)
//                                 .colorScheme
//                                 .primary
//                                 .withOpacity(0.1),
//                             borderRadius: BorderRadius.circular(16),
//                             border: Border.all(
//                               color: Theme.of(context)
//                                   .colorScheme
//                                   .primary
//                                   .withOpacity(0.3),
//                             ),
//                           ),
//                           child: Text(
//                             "#$tag",
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Theme.of(context).colorScheme.primary,
//                               fontWeight: FontWeight.w500,
//                             ),
//                           ),
//                         );
//                       }).toList(),
//                     ),
//                     const SizedBox(height: 20),
//                   ],

//                   // Return Policy Section
//                   Text(
//                     "Chính sách đổi trả",
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const SizedBox(height: 8),
//                   Container(
//                     width: double.infinity,
//                     padding: const EdgeInsets.all(16.0),
//                     decoration: BoxDecoration(
//                       color: Colors.green[50],
//                       borderRadius: BorderRadius.circular(8),
//                       border: Border.all(color: Colors.green[200]!),
//                     ),
//                     child: const Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text("✔ Đổi trả miễn phí trong 7 ngày"),
//                         SizedBox(height: 6),
//                         Text("✔ Hoàn tiền nếu sản phẩm lỗi"),
//                         SizedBox(height: 6),
//                         Text("✔ Hỗ trợ đổi size nếu không vừa"),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const Divider(height: 40, thickness: 1),

//             // Customer Reviews Section
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "Đánh giá của khách hàng",
//                         style:
//                             Theme.of(context).textTheme.titleMedium?.copyWith(
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                       ),
//                       TextButton(
//                         onPressed: () {
//                           // Điều hướng sang trang tất cả review
//                         },
//                         child: const Text("Xem tất cả"),
//                       )
//                     ],
//                   ),

//                   // Rating summary
//                   if (widget.product.totalRatings != null &&
//                       widget.product.totalRatings! >= 0) ...[
//                     Container(
//                       padding: const EdgeInsets.all(16),
//                       decoration: BoxDecoration(
//                         color: Colors.grey[50],
//                         borderRadius: BorderRadius.circular(8),
//                         border: Border.all(color: Colors.grey[300]!),
//                       ),
//                       child: Row(
//                         children: [
//                           Column(
//                             children: [
//                               Text(
//                                 "${widget.product.averageRating ?? 0}",
//                                 style: const TextStyle(
//                                   fontSize: 36,
//                                   fontWeight: FontWeight.bold,
//                                 ),
//                               ),
//                               RatingStars(
//                                   rating: widget.product.averageRating ?? 0),
//                               Text(
//                                 "${widget.product.totalRatings} đánh giá",
//                                 style: TextStyle(
//                                   color: Colors.grey[600],
//                                   fontSize: 12,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           const SizedBox(width: 20),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                   ],

//                   // Sample reviews
//                   ReviewItem(
//                     avatar: "A",
//                     name: "Nguyễn Văn A",
//                     rating: 5,
//                     comment: "Sản phẩm chất lượng, giao hàng nhanh.",
//                   ),
//                   ReviewItem(
//                     avatar: "B",
//                     name: "Trần Thị B",
//                     rating: 4,
//                     comment: "Đẹp nhưng size hơi nhỏ, nên chọn lớn hơn 1 size.",
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 30),
//           ],
//         ),
//       ),
//       bottomNavigationBar: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: (nearestStock?.availableStock ?? 0) > 0
//                       ? Theme.of(context).colorScheme.primary
//                       : Colors.grey,
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
//                 ),
//                 onPressed: (nearestStock?.availableStock ?? 0) > 0
//                     ? () {
//                         showModalBottomSheet(
//                           context: context,
//                           shape: const RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.vertical(top: Radius.circular(16)),
//                           ),
//                           builder: (context) {
//                             // Lấy giá và giảm giá
//                             final originalPrice =
//                                 widget.product.priceHistoryModel?.isNotEmpty ==
//                                         true
//                                     ? (widget.product.priceHistoryModel!.first
//                                                 .price ??
//                                             0)
//                                         .toDouble()
//                                     : 0.0;

//                             final discount =
//                                 widget.product.discounts?.isNotEmpty == true
//                                     ? (widget.product.discounts!.first
//                                                 .discountPercentage ??
//                                             0)
//                                         .toDouble()
//                                     : 0.0;

//                             final discountedPrice =
//                                 originalPrice * (1 - (discount / 100));

//                             final totalPrice = discount > 0
//                                 ? discountedPrice * quantity
//                                 : originalPrice * quantity;

//                             final variantText = [
//                               if (selectedSize.isNotEmpty)
//                                 "Size: $selectedSize",
//                               if (selectedColor != null)
//                                 "Màu: ${selectedColor!.color}"
//                             ].join(", ");

//                             final stockLeft = nearestStock?.availableStock ?? 0;

//                             return Padding(
//                               padding: const EdgeInsets.all(16),
//                               child: Column(
//                                 mainAxisSize: MainAxisSize.min,
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
//                                         child: Image.network(
//                                           selectedColor?.imageUrl ??
//                                               widget.product.imageUrls!.first,
//                                           width: 80,
//                                           height: 80,
//                                           fit: BoxFit.cover,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 12),
//                                       Expanded(
//                                         child: Column(
//                                           crossAxisAlignment:
//                                               CrossAxisAlignment.start,
//                                           children: [
//                                             Text(widget.product.name ?? "",
//                                                 style: const TextStyle(
//                                                     fontSize: 16,
//                                                     fontWeight:
//                                                         FontWeight.bold)),
//                                             const SizedBox(height: 6),
//                                             if (variantText.isNotEmpty)
//                                               Text(variantText),
//                                             Text("Số lượng chọn: $quantity"),
//                                             if (nearestStock != null) ...[
//                                               Text(
//                                                 "Chi nhánh: ${nearestStock!.branchName}",
//                                                 style: const TextStyle(
//                                                   fontSize: 12,
//                                                   color: Colors.blue,
//                                                 ),
//                                               ),
//                                               Text(
//                                                 "Còn lại: $stockLeft sản phẩm",
//                                                 style: TextStyle(
//                                                   color: stockLeft > 0
//                                                       ? Colors.green
//                                                       : Colors.red,
//                                                   fontWeight: FontWeight.w600,
//                                                 ),
//                                               ),
//                                             ],
//                                           ],
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                   const SizedBox(height: 16),

//                                   // Thành tiền có giảm giá
//                                   Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       const Text("Thành tiền:",
//                                           style: TextStyle(
//                                               fontWeight: FontWeight.w600)),
//                                       Column(
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.end,
//                                         children: [
//                                           Text(
//                                             currencyFormatter
//                                                 .format(totalPrice),
//                                             style: const TextStyle(
//                                                 fontSize: 18,
//                                                 fontWeight: FontWeight.bold,
//                                                 color: Colors.red),
//                                           ),
//                                           if (discount > 0)
//                                             Text(
//                                               currencyFormatter.format(
//                                                   originalPrice * quantity),
//                                               style: const TextStyle(
//                                                 fontSize: 14,
//                                                 decoration:
//                                                     TextDecoration.lineThrough,
//                                                 color: Colors.grey,
//                                               ),
//                                             ),
//                                         ],
//                                       ),
//                                     ],
//                                   ),

//                                   const SizedBox(height: 20),
//                                   SizedBox(
//                                     width: double.infinity,
//                                     child: ElevatedButton(
//                                       onPressed: quantity <= stockLeft
//                                           ? () {
//                                               // Thêm vào giỏ hàng logic
//                                               Navigator.pop(context);
//                                               ScaffoldMessenger.of(context)
//                                                   .showSnackBar(
//                                                 const SnackBar(
//                                                   content: Text(
//                                                       "Đã thêm vào giỏ hàng!"),
//                                                   backgroundColor: Colors.green,
//                                                 ),
//                                               );
//                                             }
//                                           : null,
//                                       style: ElevatedButton.styleFrom(
//                                         backgroundColor: quantity <= stockLeft
//                                             ? null
//                                             : Colors.grey,
//                                       ),
//                                       child: Text(
//                                         quantity <= stockLeft
//                                             ? "Xác nhận thêm"
//                                             : "Vượt quá số lượng có sẵn",
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             );
//                           },
//                         );
//                       }
//                     : null,
//                 child: Text(
//                   (nearestStock?.availableStock ?? 0) > 0
//                       ? "Thêm vào giỏ hàng"
//                       : "Hết hàng",
//                   style: const TextStyle(fontSize: 18),
//                 ),
//               ),
//               const SizedBox(width: 4),
//               Expanded(
//                 child: ElevatedButton(
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: (nearestStock?.availableStock ?? 0) > 0
//                         ? null
//                         : Colors.grey,
//                   ),
//                   onPressed: (nearestStock?.availableStock ?? 0) > 0
//                       ? () {
//                           debugPrint(
//                               "Mua ngay: size=$selectedSize, màu=$selectedColor, số lượng=$quantity");
//                           // Logic mua ngay
//                         }
//                       : null,
//                   child: Text(
//                     (nearestStock?.availableStock ?? 0) > 0
//                         ? "Mua ngay"
//                         : "Hết hàng",
//                     style: const TextStyle(fontSize: 18),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/common_widgets/custom_widget.dart';
import 'package:ecommerce_app/common_widgets/product_variant_card.dart';
import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/product/data/models/branch_stock_model.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/data/models/product_variant_model.dart';
import 'package:ecommerce_app/features/product/widget/custom_widget.dart';
import 'package:ecommerce_app/features/cart/bloc/cart_bloc.dart';
import 'package:ecommerce_app/features/cart/bloc/cart_event.dart';
import 'package:ecommerce_app/features/cart/bloc/cart_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  String selectedSize = "M";
  SimplifiedVariantModel? selectedColor;
  int quantity = 1;

  BranchStockModel? nearestStock;
  bool isLoadingStock = false;
  String? stockError;

  @override
  void initState() {
    super.initState();
    _loadNearestStock();
  }

  Future<void> _loadNearestStock() async {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      isLoadingStock = true;
      stockError = null;
    });

    try {
      final stock = await _fetchNearestStock(
          userId, widget.product.id!, selectedColor?.variantId);

      setState(() {
        nearestStock = stock;
        isLoadingStock = false;
      });
    } catch (e) {
      setState(() {
        stockError = e.toString();
        isLoadingStock = false;
      });
    }
  }

  Future<BranchStockModel?> _fetchNearestStock(
      String userId, int productId, int? variantId) async {
    try {
      final response =
          await SupabaseConfig.client.rpc('get_nearest_branch_stock', params: {
        'user_id': userId,
        'product_id': productId,
        if (variantId != null) 'variant_id': variantId,
      });

      if (response != null && response.isNotEmpty) {
        return BranchStockModel.fromJson(response.first);
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching nearest stock: $e');
      rethrow;
    }
  }

  void _addToCart() {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng đăng nhập để thêm vào giỏ hàng"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Kiểm tra stock
    final availableStock = nearestStock?.availableStock ?? 0;
    if (quantity > availableStock) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Chỉ còn $availableStock sản phẩm"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Lấy giá hiện tại (có giảm giá)
    final originalPrice = widget.product.priceHistoryModel?.isNotEmpty == true
        ? (widget.product.priceHistoryModel!.first.price ?? 0).toDouble()
        : 0.0;
    final discount = widget.product.discounts?.isNotEmpty == true
        ? (widget.product.discounts!.first.discountPercentage ?? 0).toDouble()
        : 0.0;
    final finalPrice = originalPrice * (1 - (discount / 100));

    // Debug log
    debugPrint('Adding to cart:');
    debugPrint('- productId: ${widget.product.id}');
    debugPrint('- variantId: ${selectedColor?.variantId}');
    debugPrint('- userId: $userId');
    debugPrint('- quantity: $quantity');
    debugPrint('- finalPrice: $finalPrice');

    // Thêm vào giỏ hàng với giá đã tính
    context.read<CartBloc>().add(
          AddToCart(
            widget.product.id.toString(),
            quantity,
            userId,
            selectedColor?.variantId?.toString(),
          ),
        );
  }

  void _showAddToCartModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BlocConsumer<CartBloc, CartState>(
          listener: (context, state) {
            if (state is CartOperationSuccess) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: Colors.green,
                ),
              );
            } else if (state is CartError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error ?? "Có lỗi xảy ra"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, cartState) {
            // Lấy giá và giảm giá
            final originalPrice =
                widget.product.priceHistoryModel?.isNotEmpty == true
                    ? (widget.product.priceHistoryModel!.first.price ?? 0)
                        .toDouble()
                    : 0.0;

            final discount = widget.product.discounts?.isNotEmpty == true
                ? (widget.product.discounts!.first.discountPercentage ?? 0)
                    .toDouble()
                : 0.0;

            final discountedPrice = originalPrice * (1 - (discount / 100));
            final totalPrice = discount > 0
                ? discountedPrice * quantity
                : originalPrice * quantity;
            final currencyFormatter =
                NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

            final variantText = [
              if (selectedSize.isNotEmpty) "Size: $selectedSize",
              if (selectedColor != null) "Màu: ${selectedColor!.color}"
            ].join(", ");

            final stockLeft = nearestStock?.availableStock ?? 0;
            final isLoading = cartState.isLoading;

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Xác nhận thêm vào giỏ hàng",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),

                  const Divider(),

                  // Product info
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          selectedColor?.imageUrl ??
                              widget.product.imageUrls!.first,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.product.name ?? "",
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            if (variantText.isNotEmpty)
                              Text(
                                variantText,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            Text(
                              "Số lượng: $quantity",
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (nearestStock != null) ...[
                              Text(
                                "Chi nhánh: ${nearestStock!.branchName}",
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue,
                                ),
                              ),
                              Text(
                                "Còn lại: $stockLeft sản phẩm",
                                style: TextStyle(
                                  color:
                                      stockLeft > 0 ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ],
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price breakdown
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Đơn giá:"),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  currencyFormatter.format(
                                    discount > 0
                                        ? discountedPrice
                                        : originalPrice,
                                  ),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (discount > 0)
                                  Text(
                                    currencyFormatter.format(originalPrice),
                                    style: const TextStyle(
                                      fontSize: 12,
                                      decoration: TextDecoration.lineThrough,
                                      color: Colors.grey,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Thành tiền:",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              currencyFormatter.format(totalPrice),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Add to cart button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (quantity <= stockLeft && !isLoading)
                          ? _addToCart
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (quantity <= stockLeft && !isLoading)
                            ? null
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              quantity <= stockLeft
                                  ? "Xác nhận thêm vào giỏ hàng"
                                  : "Vượt quá số lượng có sẵn",
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

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

                  // Stock Info - THÊM MỚI
                  const SizedBox(height: 8),
                  StockInfoCard(
                    isLoading: isLoadingStock,
                    error: stockError,
                    stock: nearestStock,
                  ),
                  const SizedBox(height: 16),

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
                  widget.product.simplifiedVariants!.isNotEmpty
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            Text(
                              "Các màu",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  children: widget.product.simplifiedVariants!
                                      .map((variant) {
                                    final isSelected = selectedColor == variant;
                                    return GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectedColor = variant;
                                        });
                                        // Reload stock khi đổi variant
                                        _loadNearestStock();
                                      },
                                      child: Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.3,
                                        margin:
                                            const EdgeInsets.only(right: 12),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .secondary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                            width: 2,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .colorScheme
                                                        .secondary
                                                        .withOpacity(0.5),
                                                    blurRadius: 8,
                                                    spreadRadius: 2,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : [],
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: ProductVariantCard(
                                          color: variant.color,
                                          imageUrl: variant.imageUrl.toString(),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        )
                      : const SizedBox(height: 10),

                  const SizedBox(height: 10),

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
                                // Giới hạn số lượng theo stock
                                final maxQuantity =
                                    nearestStock?.availableStock ?? 999;
                                if (quantity < maxQuantity) {
                                  setState(() {
                                    quantity++;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("Chỉ còn $maxQuantity sản phẩm"),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                }
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
                          SpecRow(
                              label: "Thương hiệu",
                              value: widget.product.brand!.brandName!),
                        if (widget.product.originCountry != null)
                          SpecRow(
                              label: "Xuất xứ",
                              value: widget.product.originCountry!),
                        if (widget.product.material != null)
                          SpecRow(
                              label: "Chất liệu",
                              value: widget.product.material!),
                        if (widget.product.color != null)
                          SpecRow(
                              label: "Màu sắc", value: widget.product.color!),
                        if (widget.product.features != null)
                          SpecRow(
                              label: "Kiểu dáng",
                              value:
                                  "${widget.product.features?["style"] ?? 'N/A'}, ${widget.product.features?["pocket"] ?? 'N/A'}"),
                        if (widget.product.weight != null)
                          SpecRow(
                              label: "Trọng lượng",
                              value: "${widget.product.weight}kg"),
                        if (widget.product.dimensions != null)
                          SpecRow(
                              label: "Kích thước",
                              value:
                                  "${widget.product.dimensions?["width_cm"] ?? 'N/A'} cm x "
                                  "${widget.product.dimensions?["height_cm"] ?? 'N/A'} cm x "
                                  "${widget.product.dimensions?["length_cm"] ?? 'N/A'} cm"),
                        if (widget.product.warrantyMonths != null)
                          SpecRow(
                              label: "Bảo hành",
                              value: "${widget.product.warrantyMonths} tháng"),
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

                  // Return Policy Section
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
                        Text("✓ Đổi trả miễn phí trong 7 ngày"),
                        SizedBox(height: 6),
                        Text("✓ Hoàn tiền nếu sản phẩm lỗi"),
                        SizedBox(height: 6),
                        Text("✓ Hỗ trợ đổi size nếu không vừa"),
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
                      widget.product.totalRatings! >= 0) ...[
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
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Sample reviews
                  ReviewItem(
                    avatar: "A",
                    name: "Nguyễn Văn A",
                    rating: 5,
                    comment: "Sản phẩm chất lượng, giao hàng nhanh.",
                  ),
                  ReviewItem(
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
          child: BlocListener<CartBloc, CartState>(
            listener: (context, state) {
              if (state is CartOperationSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Đã thêm vào giỏ hàng!"),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (state is CartError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error ?? "Có lỗi xảy ra"),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (nearestStock?.availableStock ?? 0) > 0
                          ? Theme.of(context).colorScheme.primary
                          : Colors.grey,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 14),
                    ),
                    onPressed: (nearestStock?.availableStock ?? 0) > 0
                        ? _showAddToCartModal
                        : null,
                    child: Text(
                      (nearestStock?.availableStock ?? 0) > 0
                          ? "Thêm vào giỏ hàng"
                          : "Hết hàng",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (nearestStock?.availableStock ?? 0) > 0
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey,
                    ),
                    onPressed: (nearestStock?.availableStock ?? 0) > 0
                        ? () {
                            debugPrint(
                                "Mua ngay: size=$selectedSize, màu=$selectedColor, số lượng=$quantity");
                            // Logic mua ngay
                          }
                        : null,
                    child: Text(
                      (nearestStock?.availableStock ?? 0) > 0
                          ? "Mua ngay"
                          : "Hết hàng",
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
