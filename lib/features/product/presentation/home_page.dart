import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/common_widgets/brand_card.dart';
import 'package:ecommerce_app/common_widgets/caterogy_cart.dart';
import 'package:ecommerce_app/common_widgets/custom_widget.dart';
import 'package:ecommerce_app/common_widgets/product_card.dart';
import 'package:ecommerce_app/features/chatbot/presentation/chat_page.dart';
import 'package:ecommerce_app/features/product/bloc/brand_bloc/brand_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/brand_bloc/brand_event.dart';
import 'package:ecommerce_app/features/product/bloc/brand_bloc/brand_state.dart';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:ecommerce_app/features/product/bloc/product_type_bloc/product_type_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_type_bloc/product_type_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_type_bloc/product_type_state.dart';
import 'package:ecommerce_app/features/product/presentation/brand_products_screen.dart';
import 'package:ecommerce_app/features/product/presentation/product_with_type_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with AutomaticKeepAliveClientMixin {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollDebounceTimer;

  StreamSubscription<ProductState>? _loadMoreSubscription;
  bool _isLoadingMore = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(
            LoadProductsServerFirst(
              page: 1,
              limit: 20,
              useCacheFallback: true,
            ),
          );
      context.read<BrandBloc>().add(LoadBrands());
      context.read<ProductTypeBloc>().add(const FetchProductTypes());
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _scrollDebounceTimer?.cancel();
    _loadMoreSubscription?.cancel();
    super.dispose();
  }

  void _onScroll() {
    _scrollDebounceTimer?.cancel();
    _scrollDebounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (_shouldLoadMore()) {
        _loadMoreProducts();
      }
    });
  }

  bool _shouldLoadMore() {
    if (!mounted) return false;
    if (_isLoadingMore) return false;
    if (!_isBottom) return false;

    final state = context.read<ProductBloc>().state;

    if (state.hasReachedMax) return false;
    if (state.isLoading) return false;
    if (state.isRefreshing) return false;
    if (state.products.isEmpty) return false;

    return true;
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;

    return currentScroll >= (maxScroll * 0.95) &&
        (maxScroll - currentScroll) < 200;
  }

  void _loadMoreProducts() {
    if (!mounted) return;

    final bloc = context.read<ProductBloc>();
    final currentPage = bloc.state.currentPage;

    setState(() => _isLoadingMore = true);

    print('📄 Loading page ${currentPage + 1}...');
    bloc.add(LoadMoreProducts(page: currentPage + 1));

    _loadMoreSubscription?.cancel();
    _loadMoreSubscription = bloc.stream.listen((state) {
      if (state.currentPage > currentPage && !state.isLoading) {
        if (mounted) {
          setState(() => _isLoadingMore = false);
          print('✅ Page ${state.currentPage} loaded successfully');
        }
        _loadMoreSubscription?.cancel();
      }

      if (state.hasError && !state.isLoading) {
        if (mounted) {
          setState(() => _isLoadingMore = false);
          print('❌ Error loading more: ${state.errorMessage}');
        }
        _loadMoreSubscription?.cancel();
      }
    });

    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isLoadingMore) {
        setState(() => _isLoadingMore = false);
        _loadMoreSubscription?.cancel();
        print('⚠️ Load more timeout after 10s');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final adImages = [
      "assets/images/Ad1.png",
      "assets/images/Ad2.png",
      "assets/images/Ad3.png",
    ];

    return Scaffold(
      floatingActionButton: ChatBubbleFAB(
        onPressed: () {
          Navigator.push(
            context,
            CupertinoPageRoute(builder: (context) => const ChatPage()),
          );
        },
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: _handleRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildCarousel(adImages)),
                const SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: 12)),
                const SliverToBoxAdapter(
                    child: SectionTitle(title: "Danh mục thương hiệu")),
                const SliverToBoxAdapter(child: BrandSection()),
                const SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: 12)),
                const SliverToBoxAdapter(
                    child: SectionTitle(title: "Danh mục sản phẩm")),
                const SliverToBoxAdapter(child: CategorySection()),
                const SliverPadding(
                    padding: EdgeInsets.symmetric(vertical: 12)),
                const SliverToBoxAdapter(child: ProductSectionTitle()),
                ProductGridSection(),
                SliverToBoxAdapter(
                  child: BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (_isLoadingMore && !state.hasReachedMax) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: Column(
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 8),
                                Text(
                                  'Đang tải thêm sản phẩm...',
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
                      if (state.hasReachedMax && state.products.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.check_circle_outline,
                                    color: Colors.grey[400], size: 32),
                                const SizedBox(height: 8),
                                Text(
                                  'Đã hiển thị tất cả ${state.products.length} sản phẩm',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const SliverToBoxAdapter(
                  child: SizedBox(height: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    setState(() => _isLoadingMore = false);
    _loadMoreSubscription?.cancel();

    final bloc = context.read<ProductBloc>();
    bloc.add(LoadProductsServerFirst(
      page: 1,
      limit: 20,
      useCacheFallback: false,
    ));

    await bloc.stream.firstWhere(
      (state) => !state.isRefreshing,
      orElse: () => bloc.state,
    );
  }

  Widget _buildCarousel(List<String> adImages) {
    return CarouselSlider(
      options: CarouselOptions(
        height: 200,
        autoPlay: true,
        enlargeCenterPage: true,
        viewportFraction: 0.9,
        autoPlayInterval: const Duration(seconds: 4),
      ),
      items: adImages.map((path) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.asset(
            path,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: Colors.grey[300],
              child: const Icon(Icons.image_not_supported),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ====================================================================
// WIDGET CON: Thương hiệu
// ====================================================================

class BrandSection extends StatelessWidget {
  const BrandSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrandBloc, BrandState>(
      buildWhen: (p, c) => p != c,
      builder: (context, state) {
        return switch (state) {
          BrandLoading() => _shimmer(height: 100),
          BrandError() => _errorBox('Không tải được thương hiệu'),
          BrandLoaded(:final brands) => brands.isEmpty
              ? _emptyBox('Chưa có thương hiệu nào')
              : SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: brands.length,
                    itemBuilder: (context, index) {
                      final brand = brands[index];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => BrandProductsScreen(brand: brand),
                            ),
                          );
                          if (context.mounted) {
                            context
                                .read<ProductBloc>()
                                .add(LoadProductsWithCache());
                          }
                        },
                        child: BrandCard(brand: brand),
                      );
                    },
                  ),
                ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

// ====================================================================
// WIDGET CON: Danh mục sản phẩm
// ====================================================================

class CategorySection extends StatelessWidget {
  const CategorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductTypeBloc, ProductTypeState>(
      builder: (context, state) {
        return switch (state) {
          ProductTypeLoading() => _shimmer(height: 100),
          ProductTypeFailure() => _errorBox('Không thể tải danh mục'),
          ProductTypeLoaded(:final productTypes) => productTypes.isEmpty
              ? _emptyBox('Chưa có danh mục nào')
              : SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: productTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, i) {
                      final type = productTypes[i];
                      return GestureDetector(
                        onTap: () async {
                          await Navigator.push(
                            context,
                            CupertinoPageRoute(
                              builder: (_) => ProductWithTypePage(
                                typeId: type.id.toString(),
                                typeName: type.typeName,
                              ),
                            ),
                          );
                          if (context.mounted) {
                            context
                                .read<ProductBloc>()
                                .add(LoadProductsWithCache());
                          }
                        },
                        child: CategoryCard(
                          categoryName: type.typeName,
                          imagePath: type.image_url ??
                              (i.isEven
                                  ? "assets/images/category_image.png"
                                  : "assets/images/category_image2.png"),
                        ),
                      );
                    },
                  ),
                ),
          _ => const SizedBox.shrink(),
        };
      },
    );
  }
}

// ====================================================================
// WIDGET CON: Tiêu đề sản phẩm
// ====================================================================

class ProductSectionTitle extends StatelessWidget {
  const ProductSectionTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProductBloc, ProductState>(
      buildWhen: (p, c) =>
          p.isRefreshing != c.isRefreshing ||
          p.isLoading != c.isLoading ||
          p.dataSource != c.dataSource ||
          p.errorMessage != c.errorMessage,
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Flexible(
                    child: SectionTitle(title: "Danh sách sản phẩm"),
                  ),
                  if (state.products.isNotEmpty)
                    Row(
                      children: [
                        // Refresh button
                        IconButton(
                          icon: (state.isRefreshing || state.isLoading)
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.refresh, size: 18),
                          onPressed: (state.isRefreshing || state.isLoading)
                              ? null
                              : () => context
                                  .read<ProductBloc>()
                                  .add(LoadProductsServerFirst(
                                    page: 1,
                                    limit: 20,
                                    useCacheFallback: false,
                                  )),
                          tooltip: 'Làm mới',
                        ),

                        // Data source indicator
                        _buildDataSourceBadge(state),
                      ],
                    ),
                ],
              ),

              // ✅ Warning message khi dùng cache (fallback)
              if (state.dataSource == DataSource.cache &&
                  state.errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(top: 8, bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          size: 20, color: Colors.orange[700]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          state.errorMessage!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataSourceBadge(ProductState state) {
    if (state.dataSource == DataSource.cache) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_off, size: 12, color: Colors.orange[700]),
            const SizedBox(width: 4),
            Text(
              'Offline',
              style: TextStyle(fontSize: 11, color: Colors.orange[700]),
            ),
          ],
        ),
      );
    } else if (state.dataSource == DataSource.server) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.cloud_done, size: 12, color: Colors.green[700]),
            const SizedBox(width: 4),
            Text(
              'Mới nhất',
              style: TextStyle(fontSize: 11, color: Colors.green[700]),
            ),
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
// ====================================================================
// WIDGET CON: Lưới sản phẩm
// ====================================================================

class ProductGridSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: BlocBuilder<ProductBloc, ProductState>(
        buildWhen: (p, c) =>
            p.products != c.products || p.isLoading != c.isLoading,
        builder: (context, state) {
          if (state.isLoading && state.products.isEmpty) {
            return _shimmer(height: 300);
          }

          if (state.products.isEmpty && !state.isLoading) {
            return _emptyBox('Không có sản phẩm nào');
          }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: GridView.builder(
              cacheExtent: 500,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: state.products.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 20,
                childAspectRatio: 0.55,
              ),
              itemBuilder: (_, i) {
                final product = state.products[i];
                return ProductCard(product: product);
              },
            ),
          );
        },
      ),
    );
  }
}

// ====================================================================
// TIỆN ÍCH DÙNG CHUNG
// ====================================================================

class SectionTitle extends StatelessWidget {
  final String title;
  const SectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
        child: Text(title, style: Theme.of(context).textTheme.headlineMedium),
      ),
    );
  }
}

Widget _emptyBox(String text) => SizedBox(
      height: 100,
      child: Center(
        child: Text(text, style: TextStyle(color: Colors.grey[600])),
      ),
    );

Widget _errorBox(String text) => SizedBox(
      height: 100,
      child: Center(
        child: Text(text, style: TextStyle(color: Colors.red[400])),
      ),
    );

Widget _shimmer({required double height}) {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
