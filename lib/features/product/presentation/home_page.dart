import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/common_widgets/caterogy_cart.dart';
import 'package:ecommerce_app/common_widgets/product_card.dart';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
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

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ CHỈ GỌI 1 EVENT - LoadProductsWithCache đã xử lý cache + server
      context.read<ProductBloc>().add(
            LoadProductsWithCache(
              page: 1,
              limit: 20,
              showCacheFirst: true,
            ),
          );
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollDebounceTimer?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // ✅ Debounce scroll event
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

          // Reset flag sau khi load xong
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              setState(() => _isLoadingMore = false);
            }
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

                  _buildSectionTitle(context, "Danh mục sản phẩm"),

                  _buildCategoriesSection(),

                  const SizedBox(height: 20),

                  _buildProductsSectionTitle(context),

                  const SizedBox(height: 12),

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
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
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

  Future<void> _handleRefresh() async {
    final bloc = context.read<ProductBloc>();
    bloc.add(RefreshProducts(page: 1, limit: 20));
    await bloc.stream
        .firstWhere(
          (state) => !state.isRefreshing,
          orElse: () => bloc.state,
        )
        .timeout(
          const Duration(seconds: 10),
          onTimeout: () => bloc.state,
        );
  }

  void _handleBlocListener(BuildContext context, ProductState state) {
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
  }

  Widget _buildCarouselAd(
      double screenHeight, double screenWidth, List<String> adImages) {
    return CarouselSlider(
      options: CarouselOptions(
        height: screenHeight * 0.25,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        aspectRatio: 16 / 9,
        initialPage: 0,
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

  Widget _buildCategoriesSection() {
    return SizedBox(
      height: 100,
      child: ListView.builder(
        itemCount: 6,
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => print("Click Category $index"),
            child: CategoryCard(
              categoryName: "Quần short",
              imagePath: index.isEven
                  ? "assets/images/category_image.png"
                  : "assets/images/category_image2.png",
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductsSectionTitle(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: _buildSectionTitle(context, "Danh sách sản phẩm"),
            ),
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
                  // ✅ Hiển thị data source info
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

  Widget _buildProductsGrid(ProductState state) {
    // ✅ Initial loading state
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
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 16),
              Text(
                'Đang tải sản phẩm...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    // ✅ Empty state with retry
    if (state.products.isEmpty && !state.isLoading && !state.isRefreshing) {
      return SizedBox(
        height: 300,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                "Không có sản phẩm nào",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                state.errorMessage ?? "Vui lòng thử lại sau",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
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

    // ✅ Products grid
    return Column(
      children: [
        // Refresh indicator banner
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
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[700]!,
                    ),
                  ),
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
