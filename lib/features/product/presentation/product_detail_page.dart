import 'dart:async';
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/common_widgets/custom_widget.dart';
import 'package:ecommerce_app/common_widgets/product_variant_card.dart';
import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/cart/data/model/cart_item_model.dart';
import 'package:ecommerce_app/features/order/bloc/rating_bloc/rating_bloc.dart';
import 'package:ecommerce_app/features/order/bloc/rating_bloc/rating_event.dart';
import 'package:ecommerce_app/features/order/bloc/rating_bloc/rating_state.dart';
import 'package:ecommerce_app/features/product/data/models/branch_stock_model.dart';
import 'package:ecommerce_app/features/product/data/models/index.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/presentation/checkout_page.dart';
import 'package:ecommerce_app/features/product/widget/custom_widget.dart';
import 'package:ecommerce_app/features/cart/bloc/cart_bloc.dart';
import 'package:ecommerce_app/features/cart/bloc/cart_event.dart';
import 'package:ecommerce_app/features/product/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/favorite_bloc/favorite_event.dart';
import 'package:ecommerce_app/features/product/bloc/favorite_bloc/favorite_state.dart';
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
  Map<String, dynamic>? selectedColor; // Changed from SimplifiedVariantModel
  int quantity = 1;

  BranchStockModel? nearestStock;
  bool isLoadingStock = false;
  String? stockError;

  @override
  void initState() {
    super.initState();
    _initializeDefaultSelections();
    _loadNearestStock();
  }

  void _initializeDefaultSelections() {
    // Set default color if available
    if (widget.product.simplifiedVariants?.isNotEmpty == true) {
      selectedColor = widget.product.simplifiedVariants!.first;
    }

    // Set default size if available
    final productSize = widget.product.productSize;
    if (productSize?.isNotEmpty == true) {
      selectedSize = productSize!.first.size?.sizeName ?? "M";
    }
  }

  Future<void> _loadNearestStock() async {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) return;

    setState(() {
      isLoadingStock = true;
      stockError = null;
    });

    try {
      final variantId = selectedColor?['id'] as int?; // Updated access
      final stock = await _fetchNearestStock(userId, widget.product.id!,
          variantId: variantId);

      if (mounted) {
        setState(() {
          nearestStock = stock;
          isLoadingStock = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          stockError = e.toString();
          isLoadingStock = false;
        });
      }
    }
  }

  Future<BranchStockModel?> _fetchNearestStock(String userId, int productId,
      {int? variantId}) async {
    // Fixed parameters
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
      _showSnackBar("Vui lòng đăng nhập để thêm vào giỏ hàng", Colors.orange);
      return;
    }

    // Validate stock
    final availableStock = nearestStock?.availableStock ?? 0;
    if (quantity > availableStock) {
      _showSnackBar("Chỉ còn $availableStock sản phẩm", Colors.orange);
      return;
    }
    debugPrint('Adding to cart:');
    debugPrint('- productId: ${widget.product.id}');
    debugPrint('- variantId: ${selectedColor?['id']}'); // Updated access
    debugPrint('- userId: $userId');
    debugPrint('- quantity: $quantity');
    debugPrint('- selectedSize: $selectedSize');
    debugPrint('- selectedColor: ${selectedColor?['color']}');

    // Add to cart
    context.read<CartBloc>().add(
          AddToCart(
            widget.product.id.toString(),
            quantity,
            userId,
            selectedColor?['id']?.toString(), // Updated access
          ),
        );
    Navigator.of(context).pop();
  }

  void _showSnackBar(String message, Color color) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: color,
        ),
      );
    }
  }

  void _showAddToCartModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildAddToCartModal(),
    );
  }

  String _formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(amount);
  }

  CartItem _createCartItemFromProduct() {
    final prices = _calculatePrices();

    return CartItem(
      id: DateTime.now().millisecondsSinceEpoch,
      cartId: 0,
      productId: widget.product.id!,
      variantId: selectedColor?['id'] as int?,
      quantity: quantity,
      addedAt: DateTime.now(),
      price: prices['finalPrice']!,

      // Product data
      productData: {
        'id': widget.product.id,
        'name': widget.product.name,
        'image_urls': widget.product.imageUrls,
        'price': prices['finalPrice'],
      },

      variantData: selectedColor != null
          ? {
              'id': selectedColor!['id'],
              'color': selectedColor!['color'],
              'image_url': selectedColor!['image_url'],
            }
          : null,

      nameProduct: widget.product.name,
      imageProduct: selectedColor?['image_url'] as String? ??
          (widget.product.imageUrls?.isNotEmpty == true
              ? widget.product.imageUrls!.first
              : null),
    );
  }

  void _proceedToCheckout() {
    try {
      final cartItem = _createCartItemFromProduct();
      const encoder = JsonEncoder.withIndent('  ');
      final prettyJson = encoder.convert(cartItem.toMap());
      print('Proceeding to checkout with cart item (JSON):\n$prettyJson');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CheckoutPage(
            listproduct: [cartItem],
          ),
        ),
      );
    } catch (e) {
      _showSnackBar("Có lỗi xảy ra: ${e.toString()}", Colors.red);
    }
  }

  Widget _buildBuyNowConfirmModal() {
    final prices = _calculatePrices();
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    final variantText = [
      if (selectedSize.isNotEmpty) "Size: $selectedSize",
      if (selectedColor != null) "Màu: ${selectedColor!['color']}"
    ].join(", ");

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Xác nhận mua ngay",
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

          // Product Info
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  selectedColor?['image_url'] ??
                      widget.product.imageUrls?.first ??
                      '',
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
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
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
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
                  ],
                ),
              )
            ],
          ),

          const SizedBox(height: 16),

          // Price Breakdown
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
                    const Text("Đơn giá:"),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currencyFormatter.format(prices['finalPrice']),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (prices['discount']! > 0)
                          Text(
                            currencyFormatter.format(prices['originalPrice']),
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
                      currencyFormatter.format(prices['totalPrice']),
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

          const SizedBox(height: 16),

          // Info notice
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Bạn sẽ được chuyển đến trang thanh toán",
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text("Hủy"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _proceedToCheckout();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Tiến hành thanh toán",
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartModal() {
    return BlocConsumer<CartBloc, CartState>(
      listener: (context, state) {
        if (state is CartOperationSuccess) {
          Navigator.pop(context);
          _showSnackBar(state.message, Colors.green);
        } else if (state is CartError) {
          _showSnackBar(state.error ?? "Có lỗi xảy ra", Colors.red);
        }
      },
      builder: (context, cartState) {
        final prices = _calculatePrices();
        final currencyFormatter =
            NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

        final variantText = [
          if (selectedSize.isNotEmpty) "Size: $selectedSize",
          if (selectedColor != null)
            "Màu: ${selectedColor!['color']}" // Updated access
        ].join(", ");

        final stockLeft = nearestStock?.availableStock ?? 0;
        final isLoading = cartState.isLoading;

        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildModalHeader(),
              const Divider(),
              _buildProductInfo(variantText),
              const SizedBox(height: 16),
              _buildPriceBreakdown(prices, currencyFormatter),
              const SizedBox(height: 20),
              _buildAddToCartButton(stockLeft, isLoading),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalHeader() {
    return Row(
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
    );
  }

  Widget _buildProductInfo(String variantText) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            selectedColor?['image_url'] ??
                widget.product.imageUrls?.first ??
                '', // Updated access
            width: 80,
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 80,
                height: 80,
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              );
            },
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
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
                  "Còn lại: ${nearestStock!.availableStock} sản phẩm",
                  style: TextStyle(
                    color: nearestStock!.availableStock > 0
                        ? Colors.green
                        : Colors.red,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        )
      ],
    );
  }

  Widget _buildPriceBreakdown(
      Map<String, double> prices, NumberFormat formatter) {
    return Container(
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
              const Text("Đơn giá:"),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    formatter.format(prices['finalPrice']),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  if (prices['discount']! > 0)
                    Text(
                      formatter.format(prices['originalPrice']),
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
                formatter.format(prices['totalPrice']),
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
    );
  }

  Widget _buildAddToCartButton(int stockLeft, bool isLoading) {
    final canAddToCart = quantity <= stockLeft && !isLoading;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: canAddToCart ? _addToCart : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: canAddToCart ? null : Colors.grey,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                quantity <= stockLeft
                    ? "Xác nhận thêm vào giỏ hàng"
                    : "Vượt quá số lượng có sẵn",
                style: const TextStyle(fontSize: 16),
              ),
      ),
    );
  }

  Map<String, double> _calculatePrices() {
    final originalPrice = widget.product.priceHistoryModel?.isNotEmpty == true
        ? (widget.product.priceHistoryModel!.first.price ?? 0.0).toDouble()
        : 0.0;

    double finalPrice = originalPrice;
    double discountValue = 0.0; // To display discount percentage

    final activeDiscount = widget.product.discounts?.isNotEmpty == true
        ? widget.product.discounts!.first
        : null;

    if (activeDiscount != null) {
      if (activeDiscount.discountPercentage != null &&
          activeDiscount.discountPercentage! > 0) {
        discountValue = activeDiscount.discountPercentage!.toDouble();
        finalPrice = originalPrice * (1 - (discountValue / 100));
      } else if (activeDiscount.discountAmount != null &&
          activeDiscount.discountAmount! > 0) {
        finalPrice = originalPrice - activeDiscount.discountAmount!.toDouble();
        if (finalPrice < 0) finalPrice = 0;
        // Calculate percentage for display purposes if needed
        if (originalPrice > 0) {
          discountValue =
              (activeDiscount.discountAmount! / originalPrice) * 100;
        }
      }
    }

    final totalPrice = finalPrice * quantity;

    return {
      'originalPrice': originalPrice,
      'discount': discountValue, // This is now a percentage for display
      'finalPrice': finalPrice,
      'totalPrice': totalPrice,
    };
  }

  void _onVariantSelected(Map<String, dynamic> variant) {
    setState(() {
      selectedColor = variant;
    });
    // Reload stock when variant changes
    _loadNearestStock();
  }

  void _onQuantityChanged(int delta) {
    final maxQuantity = nearestStock?.availableStock ?? 999;
    final newQuantity = quantity + delta;

    if (newQuantity >= 1 && newQuantity <= maxQuantity) {
      setState(() {
        quantity = newQuantity;
      });
    } else if (newQuantity > maxQuantity) {
      _showSnackBar("Chỉ còn $maxQuantity sản phẩm", Colors.orange);
    }
  }

  @override
  Widget build(BuildContext context) {
    final productSize = widget.product.productSize;
    final List<String> sizes = productSize
            ?.map((element) => element.size?.sizeName ?? '')
            .where((s) => s.isNotEmpty)
            .toList() ??
        [];
    final List<String> images = widget.product.imageUrls ?? [];
    final prices = _calculatePrices();
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
        actions: [
          BlocBuilder<FavoriteBloc, FavoriteState>(
            builder: (context, state) {
              final isFavorite =
                  state.favoriteProductIds.contains(widget.product.id);
              return IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color:
                      isFavorite ? Colors.red : Theme.of(context).primaryColor,
                ),
                onPressed: () {
                  final userId = SupabaseConfig.client.auth.currentUser?.id;
                  if (userId != null) {
                    context
                        .read<FavoriteBloc>()
                        .add(ToggleFavorite(widget.product.id));
                  } else {
                    _showSnackBar("Vui lòng đăng nhập để sử dụng chức năng này",
                        Colors.orange);
                  }
                },
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.share, color: Theme.of(context).primaryColor),
            onPressed: () {
              // Share functionality
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildImageCarousel(images),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildProductHeader(),
                  const SizedBox(height: 16),
                  _buildStockInfo(),
                  const SizedBox(height: 16),
                  _buildProductDescription(),
                  const SizedBox(height: 16),
                  _buildRatingSection(),
                  const SizedBox(height: 8),
                  _buildPriceSection(prices, currencyFormatter),
                  const SizedBox(height: 20),
                  if (sizes.isNotEmpty) _buildSizeSelection(sizes),
                  if (widget.product.simplifiedVariants?.isNotEmpty == true)
                    _buildColorSelection(),
                  const SizedBox(height: 10),
                  _buildQuantitySelection(),
                  const SizedBox(height: 20),
                  _buildProductSpecifications(),
                  const SizedBox(height: 20),
                  _buildCareInstructions(),
                  _buildTags(),
                  _buildReturnPolicy(),
                ],
              ),
            ),
            const Divider(height: 40, thickness: 1),
            _buildReviewsSection(),
            const SizedBox(height: 30),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildImageCarousel(List<String> images) {
    if (images.isEmpty) {
      return Container(
        height: 400,
        color: Colors.grey[300],
        child: const Center(
          child: Icon(Icons.image_not_supported, size: 50),
        ),
      );
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 400,
            enlargeCenterPage: true,
            viewportFraction: 1,
            autoPlay: true,
            autoPlayInterval: const Duration(seconds: 4),
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
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(
                    child: Icon(Icons.image_not_supported, size: 50),
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  width: double.infinity,
                  height: 400,
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              },
            );
          }).toList(),
        ),
        // Dots indicator
        if (images.length > 1)
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
    );
  }

  Widget _buildProductHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.product.name ?? "Tên sản phẩm",
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.product.brand?.brandName != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                const Icon(Icons.verified, size: 16, color: Colors.blue),
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
        if (widget.product.sku != null)
          Text(
            "Mã SP: ${widget.product.sku}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
      ],
    );
  }

  Widget _buildStockInfo() {
    return StockInfoCard(
      isLoading: isLoadingStock,
      error: stockError,
      stock: nearestStock,
    );
  }

  Widget _buildProductDescription() {
    return Text(
      widget.product.description ?? "Không có mô tả",
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildRatingSection() {
    return Row(
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
    );
  }

  Widget _buildPriceSection(
      Map<String, double> prices, NumberFormat formatter) {
    return Row(
      children: [
        if (prices['discount']! > 0) ...[
          Text(
            formatter.format(prices['finalPrice']),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            formatter.format(prices['originalPrice']),
            style: TextStyle(
              fontSize: 16,
              decoration: TextDecoration.lineThrough,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "-${prices['discount']!.toInt()}%",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ] else ...[
          Text(
            formatter.format(prices['originalPrice']),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSizeSelection(List<String> sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildColorSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Các màu",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.2,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.product.simplifiedVariants!.length,
            itemBuilder: (context, index) {
              final variant = widget.product.simplifiedVariants![index];
              final isSelected =
                  selectedColor?['id'] == variant['id']; // Updated comparison

              return GestureDetector(
                onTap: () => _onVariantSelected(variant),
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.primary,
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
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ProductVariantCard(
                    color: variant['color']?.toString() ?? '',
                    imageUrl: variant['image_url']?.toString() ?? '',
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildQuantitySelection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Số lượng",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Row(
          children: [
            IconButton(
              onPressed: () => _onQuantityChanged(-1),
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
              onPressed: () => _onQuantityChanged(1),
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProductSpecifications() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
              if (widget.product.brand?.brandName != null)
                SpecRow(
                    label: "Thương hiệu",
                    value: widget.product.brand!.brandName!),
              if (widget.product.originCountry != null)
                SpecRow(label: "Xuất xứ", value: widget.product.originCountry!),
              if (widget.product.material != null)
                SpecRow(label: "Chất liệu", value: widget.product.material!),
              if (widget.product.color != null)
                SpecRow(label: "Màu sắc", value: widget.product.color!),
              if (widget.product.features != null)
                SpecRow(
                  label: "Kiểu dáng",
                  value:
                      "${widget.product.features?["style"] ?? 'N/A'}, ${widget.product.features?["pocket"] ?? 'N/A'}",
                ),
              if (widget.product.weight != null)
                SpecRow(
                    label: "Trọng lượng", value: "${widget.product.weight}kg"),
              if (widget.product.dimensions != null)
                SpecRow(
                  label: "Kích thước",
                  value:
                      "${widget.product.dimensions?["width_cm"] ?? 'N/A'} cm x "
                      "${widget.product.dimensions?["height_cm"] ?? 'N/A'} cm x "
                      "${widget.product.dimensions?["length_cm"] ?? 'N/A'} cm",
                ),
              if (widget.product.warrantyMonths != null)
                SpecRow(
                    label: "Bảo hành",
                    value: "${widget.product.warrantyMonths} tháng"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCareInstructions() {
    if (widget.product.careInstructions == null) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
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
      ],
    );
  }

  Widget _buildTags() {
    if (widget.product.tags?.isEmpty != false) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
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
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
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
      ],
    );
  }

  Widget _buildReturnPolicy() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
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
    );
  }

  Widget _buildReviewsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Đánh giá của khách hàng",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to all reviews page
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (context) => BlocProvider.value(
                  //       value: context.read<RatingBloc>(),
                  //       child: ProductRatingsPage(
                  //         productId: widget.product.id.toString(),
                  //         productName: widget.product.name ?? '',
                  //       ),
                  //     ),
                  //   ),
                  // );
                },
                child: const Text("Xem tất cả"),
              )
            ],
          ),

          // Use BlocBuilder to fetch and display real ratings
          BlocBuilder<RatingBloc, RatingState>(
            builder: (context, state) {
              // Trigger fetch on first build
              if (state is RatingInitial) {
                context.read<RatingBloc>().add(
                      FetchProductRatings(widget.product.id.toString()),
                    );
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is RatingLoading) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              if (state is RatingError) {
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red[300]),
                        const SizedBox(height: 8),
                        Text(
                          'Không thể tải đánh giá',
                          style: TextStyle(color: Colors.red[700]),
                        ),
                        TextButton(
                          onPressed: () {
                            context.read<RatingBloc>().add(
                                  FetchProductRatings(
                                      widget.product.id.toString()),
                                );
                          },
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              if (state is ProductRatingsLoaded) {
                final ratings = state.ratings;

                if (ratings.isEmpty) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: const Center(
                      child: Column(
                        children: [
                          Icon(Icons.rate_review_outlined,
                              size: 48, color: Colors.grey),
                          SizedBox(height: 8),
                          Text(
                            "Chưa có đánh giá nào",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            "Hãy là người đầu tiên đánh giá sản phẩm này!",
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Display rating summary and reviews
                return Column(
                  children: [
                    _buildRatingSummary(ratings),
                    const SizedBox(height: 16),
                    _buildRealReviews(ratings),
                  ],
                );
              }

              // Default: show no reviews
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: const Center(
                  child: Text(
                    "Chưa có đánh giá nào",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRealReviews(List<ProductRatingModel> ratings) {
    // Show only first 3 reviews
    final displayRatings = ratings.take(3).toList();

    return Column(
      children: displayRatings.map((rating) {
        return RealReviewItem(rating: rating);
      }).toList(),
    );
  }

  Widget _buildRatingSummary(List<ProductRatingModel> ratings) {
    // Calculate rating distribution
    final distribution = {
      5: ratings.where((r) => r.rating == 5).length,
      4: ratings.where((r) => r.rating == 4).length,
      3: ratings.where((r) => r.rating == 3).length,
      2: ratings.where((r) => r.rating == 2).length,
      1: ratings.where((r) => r.rating == 1).length,
    };

    final totalRatings = ratings.length;
    final averageRating = totalRatings > 0
        ? ratings.map((r) => r.rating).reduce((a, b) => a + b) / totalRatings
        : 0.0;

    return Container(
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
                averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              RatingStars(rating: averageRating),
              Text(
                "$totalRatings đánh giá",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRatingBar("5⭐",
                    totalRatings > 0 ? distribution[5]! / totalRatings : 0),
                _buildRatingBar("4⭐",
                    totalRatings > 0 ? distribution[4]! / totalRatings : 0),
                _buildRatingBar("3⭐",
                    totalRatings > 0 ? distribution[3]! / totalRatings : 0),
                _buildRatingBar("2⭐",
                    totalRatings > 0 ? distribution[2]! / totalRatings : 0),
                _buildRatingBar("1⭐",
                    totalRatings > 0 ? distribution[1]! / totalRatings : 0),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          SizedBox(
            width: 30,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: LinearProgressIndicator(
              value: percentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            "${(percentage * 100).toInt()}%",
            style: const TextStyle(fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildSampleReviews() {
    return Column(
      children: [
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
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: BlocListener<CartBloc, CartState>(
          listener: (context, state) {
            if (state is CartOperationSuccess) {
              _showSnackBar("Đã thêm vào giỏ hàng!", Colors.green);
            } else if (state is CartError) {
              _showSnackBar(state.error ?? "Có lỗi xảy ra", Colors.red);
            }
          },
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (nearestStock?.availableStock ?? 0) > 0
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: (nearestStock?.availableStock ?? 0) > 0
                      ? _showAddToCartModal
                      : null,
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                  label: Text(
                    (nearestStock?.availableStock ?? 0) > 0
                        ? "Thêm giỏ hàng"
                        : "Hết hàng",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: (nearestStock?.availableStock ?? 0) > 0
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.grey,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed:
                      (nearestStock?.availableStock ?? 0) > 0 ? _buyNow : null,
                  icon: const Icon(Icons.flash_on, size: 20),
                  label: Text(
                    (nearestStock?.availableStock ?? 0) > 0
                        ? "Mua ngay"
                        : "Hết hàng",
                    style: const TextStyle(fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _buyNow() {
    final userId = SupabaseConfig.client.auth.currentUser?.id;
    if (userId == null) {
      _showSnackBar("Vui lòng đăng nhập để mua hàng", Colors.orange);
      return;
    }

    // Validate selections
    if (selectedColor == null &&
        widget.product.simplifiedVariants?.isNotEmpty == true) {
      _showSnackBar("Vui lòng chọn màu sắc", Colors.orange);
      return;
    }

    final availableStock = nearestStock?.availableStock ?? 0;
    if (availableStock <= 0) {
      _showSnackBar("Sản phẩm đã hết hàng", Colors.red);
      return;
    }

    if (quantity > availableStock) {
      _showSnackBar("Chỉ còn $availableStock sản phẩm", Colors.orange);
      return;
    }

    // Hiển thị modal xác nhận mua ngay
    _showBuyNowConfirmModal();
  }

  void _showBuyNowConfirmModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildBuyNowConfirmModal(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

// Helper widget for displaying specification rows
class SpecRow extends StatelessWidget {
  final String label;
  final String value;

  const SpecRow({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
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
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }
}

// Helper widget for displaying review items
class ReviewItem extends StatelessWidget {
  final String avatar;
  final String name;
  final int rating;
  final String comment;

  const ReviewItem({
    super.key,
    required this.avatar,
    required this.name,
    required this.rating,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  avatar,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  RatingStars(rating: rating.toDouble()),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(comment),
        ],
      ),
    );
  }
}

class RealReviewItem extends StatelessWidget {
  final ProductRatingModel rating;

  const RealReviewItem({
    Key? key,
    required this.rating,
  }) : super(key: key);

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return "Hôm nay";
      } else if (difference.inDays == 1) {
        return "Hôm qua";
      } else if (difference.inDays < 7) {
        return "${difference.inDays} ngày trước";
      } else if (difference.inDays < 30) {
        return "${(difference.inDays / 7).floor()} tuần trước";
      } else if (difference.inDays < 365) {
        return "${(difference.inDays / 30).floor()} tháng trước";
      } else {
        return "${(difference.inDays / 365).floor()} năm trước";
      }
    } catch (e) {
      return dateStr;
    }
  }

  String _getInitials(String? userId) {
    if (userId == null || userId.isEmpty) return "?";
    return userId.substring(0, 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(
                  _getInitials(rating.userId),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          rating.isAnonymous == true
                              ? "Người dùng ẩn danh"
                              : "Người mua",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        if (rating.isVerifiedPurchase == true) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            size: 14,
                            color: Colors.green[700],
                          ),
                        ],
                      ],
                    ),
                    Row(
                      children: [
                        RatingStars(rating: rating.rating.toDouble()),
                        const SizedBox(width: 8),
                        Text(
                          _formatDate(rating.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Title
          if (rating.title != null && rating.title!.isNotEmpty) ...[
            Text(
              rating.title!,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 4),
          ],

          // Comment
          if (rating.comment != null && rating.comment!.isNotEmpty) ...[
            Text(
              rating.comment!,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
          ],

          // Pros
          if (rating.pros != null && rating.pros!.isNotEmpty) ...[
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: rating.pros!.take(2).map((pro) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add, size: 12, color: Colors.green[700]),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          pro,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
          ],

          // Cons
          if (rating.cons != null && rating.cons!.isNotEmpty) ...[
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: rating.cons!.take(2).map((con) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.red[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.remove, size: 12, color: Colors.red[700]),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          con,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.red[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 4),
          ],

          // Images
          if (rating.images != null && rating.images!.isNotEmpty) ...[
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount:
                    rating.images!.length > 3 ? 3 : rating.images!.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      rating.images![index],
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stack) {
                        return Container(
                          width: 60,
                          height: 60,
                          color: Colors.grey[200],
                          child: Icon(Icons.image, color: Colors.grey[400]),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],

          // Helpful count
          if (rating.helpfulCount != null && rating.helpfulCount! > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.thumb_up, size: 12, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  "${rating.helpfulCount} người thấy hữu ích",
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
