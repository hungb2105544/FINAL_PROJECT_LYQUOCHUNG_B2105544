// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:ecommerce_app/common_widgets/caterogy_cart.dart';
// import 'package:ecommerce_app/common_widgets/product_card.dart';
// import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
// import 'package:ecommerce_app/features/product/bloc/product_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:lottie/lottie.dart';

// class HomePage extends StatelessWidget {
//   const HomePage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final screenWidth = MediaQuery.of(context).size.width;

//     final List<String> adImages = [
//       "assets/images/Ad1.png",
//       "assets/images/Ad2.png",
//       "assets/images/Ad3.png",
//     ];
//     return Scaffold(
//       appBar: AppBar(
//         title: Image.asset(
//           'assets/images/splash_logo.png',
//           height: 46,
//         ),
//         actions: [
//           IconButton(
//             icon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 25),
//             onPressed: () => print("Click Search"),
//           ),
//           const SizedBox(width: 12),
//         ],
//         leading: IconButton(
//           icon: const Icon(Icons.menu, size: 28),
//           onPressed: () => print("Click Menu"),
//         ),
//         centerTitle: true,
//       ),
//       body: SafeArea(
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: SingleChildScrollView(
//             child: Column(
//               children: [
//                 // Quảng cáo
//                 Container(
//                     child: CarouselSlider(
//                   options: CarouselOptions(
//                     height: screenHeight * 0.25,
//                     autoPlay: true,
//                     enlargeCenterPage: true,
//                     viewportFraction: 0.9,
//                     aspectRatio: 16 / 9,
//                     initialPage: 0,
//                   ),
//                   items: adImages.map((imagePath) {
//                     return ClipRRect(
//                       borderRadius: BorderRadius.circular(8),
//                       child: Image.asset(
//                         imagePath,
//                         width: screenWidth * 0.9,
//                         fit: BoxFit.cover,
//                       ),
//                     );
//                   }).toList(),
//                 )),
//                 const SizedBox(height: 20),

//                 // Tiêu đề Danh mục
//                 _buildSectionTitle(context, "Danh mục sản phẩm"),

//                 // Danh mục sản phẩm
//                 SizedBox(
//                   height: 100,
//                   child: ListView.builder(
//                     itemCount: 6,
//                     scrollDirection: Axis.horizontal,
//                     itemBuilder: (context, index) {
//                       return GestureDetector(
//                         onTap: () => print("Click Category $index"),
//                         child: CategoryCard(
//                           categoryName: "Quần short",
//                           imagePath: index.isEven
//                               ? "assets/images/category_image.png"
//                               : "assets/images/category_image2.png",
//                         ),
//                       );
//                     },
//                   ),
//                 ),

//                 const SizedBox(height: 20),

//                 // Tiêu đề Sản phẩm
//                 _buildSectionTitle(context, "Danh sách sản phẩm"),

//                 const SizedBox(height: 12),

//                 // Grid sản phẩm
//                 BlocBuilder<ProductBloc, ProductState>(
//                   builder: (context, state) {
//                     if (state.isLoading) {
//                       Future.delayed(Duration(seconds: 3), () {
//                         return Center(
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               Lottie.asset("assets/lottie/loading_viemode.json",
//                                   height: 50, width: 50, fit: BoxFit.cover),
//                             ],
//                           ),
//                         );
//                       });
//                     }

//                     if (state.errorMessage != null) {
//                       return Center(child: Text(state.errorMessage!));
//                     }

//                     if (state.products.isEmpty) {
//                       return const Center(child: Text("Không có sản phẩm nào"));
//                     }

//                     return GridView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: state.products.length,
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                         crossAxisCount: 2,
//                         crossAxisSpacing: 12,
//                         mainAxisSpacing: 20,
//                         childAspectRatio: 0.55,
//                       ),
//                       itemBuilder: (context, index) {
//                         final product = state.products[index];
//                         return GestureDetector(
//                           onTap: () => print("Click Product ${product.name}"),
//                           child: ProductCard(
//                               product: product), // truyền dữ liệu thật
//                         );
//                       },
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   // Tiêu đề section tái sử dụng
//   Widget _buildSectionTitle(BuildContext context, String title) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
//         child: Text(
//           title,
//           style: Theme.of(context).textTheme.headlineMedium,
//         ),
//       ),
//     );
//   }
// }
import 'package:carousel_slider/carousel_slider.dart';
import 'package:ecommerce_app/common_widgets/caterogy_cart.dart';
import 'package:ecommerce_app/common_widgets/product_card.dart';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lottie/lottie.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // FIX: Load products with cache-first strategy on page init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductBloc>().add(
            LoadProductsWithCache(page: 1, limit: 20, showCacheFirst: true),
          );
    });

    // Setup pagination listener
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      final currentState = context.read<ProductBloc>().state;
      if (!currentState.hasReachedMax && !currentState.isLoading) {
        context.read<ProductBloc>().add(
              LoadMoreProducts(page: currentState.currentPage + 1),
            );
      }
    }
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
      appBar: AppBar(
        title: Image.asset(
          'assets/images/splash_logo.png',
          height: 46,
        ),
        actions: [
          IconButton(
            icon: const Icon(FontAwesomeIcons.magnifyingGlass, size: 25),
            onPressed: () => print("Click Search"),
          ),
          // FIX: Add cache status indicator
          BlocBuilder<ProductBloc, ProductState>(
            builder: (context, state) {
              if (state.isFromCache) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Icon(
                    Icons.offline_bolt,
                    color: Colors.orange,
                    size: 20,
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
          const SizedBox(width: 12),
        ],
        leading: IconButton(
          icon: const Icon(Icons.menu, size: 28),
          onPressed: () => print("Click Menu"),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: RefreshIndicator(
          // FIX: Add pull-to-refresh functionality
          onRefresh: () async {
            context
                .read<ProductBloc>()
                .add(RefreshProducts(page: 1, limit: 20));

            // Wait for refresh to complete
            await Future.delayed(const Duration(milliseconds: 500));
            final state = context.read<ProductBloc>().state;
            while (state.isRefreshing) {
              await Future.delayed(const Duration(milliseconds: 100));
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                children: [
                  // Quảng cáo
                  _buildCarouselAd(screenHeight, screenWidth, adImages),
                  const SizedBox(height: 20),

                  // Tiêu đề Danh mục
                  _buildSectionTitle(context, "Danh mục sản phẩm"),

                  // Danh mục sản phẩm
                  _buildCategoriesSection(),

                  const SizedBox(height: 20),

                  // Tiêu đề Sản phẩm với cache status
                  _buildProductsSectionTitle(context),

                  const SizedBox(height: 12),

                  // FIX: Improved BlocBuilder with better loading states
                  BlocConsumer<ProductBloc, ProductState>(
                    listener: (context, state) {
                      // FIX: Show snackbar for errors
                      if (state.hasError) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(state.errorMessage!),
                            backgroundColor: Colors.red[600],
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
                    },
                    builder: (context, state) {
                      return _buildProductsGrid(state);
                    },
                  ),

                  // FIX: Add loading indicator for pagination
                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state.isLoading && state.products.isNotEmpty) {
                        return Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Center(
                            child: CircularProgressIndicator(),
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
            // FIX: Add cache status and refresh button
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (state.products.isNotEmpty)
                  TextButton.icon(
                    onPressed: state.isRefreshing
                        ? null
                        : () {
                            context.read<ProductBloc>().add(RefreshProducts());
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
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildProductsGrid(ProductState state) {
    // FIX: Better loading state handling
    if (state.isLoading && state.products.isEmpty) {
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

    // FIX: Better empty state
    if (state.products.isEmpty && !state.isLoading) {
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
              ElevatedButton.icon(
                onPressed: () {
                  context.read<ProductBloc>().add(LoadProductsWithCache());
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    // FIX: Products grid with proper handling
    return Column(
      children: [
        // Show refresh indicator when loading fresh data over cache
        if (state.isRefreshing && state.products.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(width: 8),
                Text(
                  state.dataSourceMessage,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[700],
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

  // Tiêu đề section tái sử dụng
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
