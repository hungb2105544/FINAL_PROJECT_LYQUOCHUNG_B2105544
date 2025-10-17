import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/common_widgets/brand_card.dart';
import 'package:ecommerce_app/common_widgets/caterogy_cart.dart';
import 'package:ecommerce_app/common_widgets/product_card.dart';
import 'package:ecommerce_app/features/product/bloc/brand_bloc/brand_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/brand_bloc/brand_event.dart';
import 'package:ecommerce_app/features/product/bloc/brand_bloc/brand_state.dart';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:ecommerce_app/features/product/bloc/product_type_bloc/product_type_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_type_bloc/product_type_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_type_bloc/product_type_state.dart';
import 'package:ecommerce_app/features/product/presentation/product_with_type_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollDebounceTimer;
  bool _isLoadingMore = false;
  bool _hasShownRealtimeSnack = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Load dữ liệu ban đầu (cache + server)
      context.read<ProductBloc>().add(
            LoadProductsWithCache(
              page: 1,
              limit: 20,
              showCacheFirst: true,
            ),
          );
      context.read<BrandBloc>().add(LoadBrands());
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollDebounceTimer?.cancel();
    super.dispose();
  }

  // =====================================================
  // 🔁 Xử lý scroll để load thêm sản phẩm
  // =====================================================
  void _onScroll() {
    if (_scrollDebounceTimer?.isActive ?? false) {
      _scrollDebounceTimer!.cancel();
    }

    _scrollDebounceTimer = Timer(const Duration(milliseconds: 200), () {
      if (_isBottom && !_isLoadingMore) {
        final currentState = context.read<ProductBloc>().state;

        if (!currentState.hasReachedMax && !currentState.isLoading) {
          setState(() => _isLoadingMore = true);

          context.read<ProductBloc>().add(
                LoadMoreProducts(page: currentState.currentPage + 1),
              );

          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) setState(() => _isLoadingMore = false);
          });
        }
      }
    });
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  // =====================================================
  // 🧱 UI chính
  // =====================================================
  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    final List<String> adImages = [
      "assets/images/Ad1.png",
      "assets/images/Ad2.png",
      "assets/images/Ad3.png",
    ];

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _handleRefresh,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  _buildCarouselAd(screenHeight, screenWidth, adImages),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, "Danh mục thương hiệu"),
                  _buildBrandsSection(),
                  const SizedBox(height: 20),
                  _buildSectionTitle(context, "Danh mục sản phẩm"),
                  _buildCategoriesSection(),
                  const SizedBox(height: 20),
                  _buildProductsSectionTitle(context),
                  const SizedBox(height: 12),

                  // =====================================================
                  // 🧩 Hiển thị danh sách sản phẩm
                  // =====================================================
                  BlocConsumer<ProductBloc, ProductState>(
                    listener: _handleBlocListener,
                    builder: (context, state) {
                      return _buildProductsGrid(state);
                    },
                  ),

                  // ✅ Loading indicator cho pagination
                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state.isLoading &&
                          state.products.isNotEmpty &&
                          !state.hasReachedMax) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  // ✅ End of list indicator
                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state.hasReachedMax && state.products.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            'Đã hiển thị tất cả sản phẩm',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // =====================================================
  // 🏷️ Thương hiệu nổi bật
  // =====================================================
  Widget _buildBrandsSection() {
    return BlocBuilder<BrandBloc, BrandState>(
      builder: (context, state) {
        return switch (state) {
          // Loading state
          BrandLoading() => const SizedBox(
              height: 110,
              child: Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(strokeWidth: 3),
                ),
              ),
            ),

          // Error state
          BrandError(:final message) => SizedBox(
              height: 110,
              child: Center(
                child: Text(
                  'Lỗi tải thương hiệu: Vui lòng thử lại',
                  style: TextStyle(color: Colors.red[400]),
                ),
              ),
            ),

          // Loaded state
          BrandLoaded(:final brands) => brands.isEmpty
              ? const SizedBox(
                  height: 110,
                  child: Center(child: Text('Chưa có thương hiệu nào')),
                )
              : SizedBox(
                  height:
                      120, // Chiều cao phù hợp cho danh sách thương hiệu ngang
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: brands.length,
                    itemBuilder: (context, index) {
                      final brand = brands[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 12.0),
                        child: GestureDetector(
                          onTap: () {
                            print("Click Brand ${brand.brandName}");
                          },
                          // Giả định BrandModel có thuộc tính brand_name và brand_logo_url
                          child: BrandCard(
                            brand: brand,
                          ),
                        ),
                      );
                    },
                  ),
                ),

          // Initial state
          BrandInitial() => const SizedBox(height: 110),
          BrandState() => throw UnimplementedError(),
        };
      },
    );
  }

  // =====================================================
  // 🔄 Kéo để refresh thủ công
  // =====================================================
  Future<void> _handleRefresh() async {
    final bloc = context.read<ProductBloc>();
    bloc.add(RefreshProducts(page: 1, limit: 20));
    await bloc.stream
        .firstWhere(
          (state) => !state.isRefreshing,
          orElse: () => bloc.state,
        )
        .timeout(const Duration(seconds: 10), onTimeout: () => bloc.state);
  }

  // =====================================================
  // 📢 Lắng nghe thay đổi state để hiển thị SnackBar hoặc lỗi
  // =====================================================
  void _handleBlocListener(BuildContext context, ProductState state) {
    // 🧩 Nếu có lỗi
    if (state.hasError && state.errorMessage != null) {
      if (state.products.isEmpty || !state.errorMessage!.contains('đã lưu')) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.errorMessage!),
            backgroundColor: Colors.red[600],
            duration: const Duration(seconds: 3),
            action: SnackBarAction(
              label: 'Thử lại',
              textColor: Colors.white,
              onPressed: () {
                context.read<ProductBloc>().add(
                      LoadProductsWithCache(page: 1, limit: 20),
                    );
              },
            ),
          ),
        );
      }
    }

    // 🧩 Hiển thị snackbar khi nhận realtime update
    if (!state.isRefreshing &&
        state.dataSource == DataSource.server &&
        !_hasShownRealtimeSnack) {
      _hasShownRealtimeSnack = true;
      print("Dữ liệu loading thành công");
    }
  }

  // =====================================================
  // 🎞️ Slider quảng cáo
  // =====================================================
  Widget _buildCarouselAd(
      double screenHeight, double screenWidth, List<String> adImages) {
    return CarouselSlider(
      options: CarouselOptions(
        height: screenHeight * 0.25,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 16 / 9,
        autoPlayInterval: const Duration(seconds: 4),
      ),
      items: adImages.map((imagePath) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            imagePath,
            width: screenWidth * 0.9,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Icon(Icons.image_not_supported),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  // =====================================================
  // 📦 Danh mục sản phẩm
  // =====================================================
  Widget _buildCategoriesSection() {
    return BlocBuilder<ProductTypeBloc, ProductTypeState>(
      builder: (context, state) {
        return switch (state) {
          // Loading state
          ProductTypeLoading() => SizedBox(
              height: 100,
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),

          // Error state
          ProductTypeFailure(:final message) => SizedBox(
              height: 100,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 32, color: Colors.red[400]),
                    const SizedBox(height: 8),
                    Text(
                      'Không thể tải danh mục',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context.read<ProductTypeBloc>().add(
                              const FetchProductTypes(),
                            );
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),

          // Loaded state
          ProductTypeLoaded(:final productTypes) => productTypes.isEmpty
              ? SizedBox(
                  height: 100,
                  child: Center(
                    child: Text(
                      'Chưa có danh mục nào',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
              : SizedBox(
                  height: 100,
                  child: ListView.builder(
                    itemCount: productTypes.length,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (context, index) {
                      final productType = productTypes[index];
                      return GestureDetector(
                        onTap: () async {
                          // Đợi cho đến khi quay lại từ trang ProductWithTypePage
                          await Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (context) => ProductWithTypePage(
                                typeId: productType.id.toString(),
                                typeName: productType.typeName,
                              ),
                            ),
                          );

                          // Sau khi quay lại, tải lại dữ liệu cho trang chủ
                          if (mounted) {
                            context
                                .read<ProductBloc>()
                                .add(LoadProductsWithCache());
                          }
                        },
                        child: CategoryCard(
                          categoryName: productType.typeName,
                          // Sử dụng image từ productType nếu có, nếu không dùng default
                          imagePath: productType.image_url ??
                              (index.isEven
                                  ? "assets/images/category_image.png"
                                  : "assets/images/category_image2.png"),
                        ),
                      );
                    },
                  ),
                ),

          // Initial state
          ProductTypeInitial() => const SizedBox(height: 100),
        };
      },
    );
  }

  // =====================================================
  // 🏷️ Tiêu đề danh sách sản phẩm
  // =====================================================
  Widget _buildProductsSectionTitle(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(child: _buildSectionTitle(context, "Danh sách sản phẩm")),
            if (state.products.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: state.isRefreshing
                        ? null
                        : () {
                            context
                                .read<ProductBloc>()
                                .add(RefreshProducts(page: 1, limit: 20));
                          },
                    icon: state.isRefreshing
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.refresh, size: 16),
                    label: Text(
                      state.isRefreshing ? 'Đang tải...' : 'Làm mới',
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  if (state.isFromCache && !state.isRefreshing)
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cached, size: 12, color: Colors.orange),
                          const SizedBox(width: 4),
                          Text(
                            'Dữ liệu đã lưu',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        );
      },
    );
  }

  // =====================================================
  // 🧱 Hiển thị danh sách sản phẩm
  // =====================================================
  Widget _buildProductsGrid(ProductState state) {
    if (state.isLoading && state.products.isEmpty && !state.isRefreshing) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Lottie.asset(
                "assets/lottie/loading_viemode.json",
                height: 100,
                width: 100,
              ),
              const SizedBox(height: 16),
              Text(
                'Đang tải sản phẩm...',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    if (state.products.isEmpty && !state.isLoading && !state.isRefreshing) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2_outlined,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                "Không có sản phẩm nào",
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? "Vui lòng thử lại sau",
                style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ProductBloc>().add(
                        LoadProductsWithCache(page: 1, limit: 20),
                      );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Grid sản phẩm
    return Column(
      children: [
        if (state.isRefreshing && state.products.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue[200]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.blue),
                ),
                const SizedBox(width: 8),
                Text(
                  state.dataSourceMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.products.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 20,
            childAspectRatio: 0.55,
          ),
          itemBuilder: (context, index) {
            final product = state.products[index];
            return GestureDetector(
              onTap: () => print("Click Product ${product.name}"),
              child: ProductCard(product: product),
            );
          },
        ),
      ],
    );
  }

  // =====================================================
  // 🏷️ Tiêu đề section
  // =====================================================
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        child: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
