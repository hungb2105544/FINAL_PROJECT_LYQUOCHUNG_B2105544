// import 'package:ecommerce_app/common_widgets/product_card.dart';
// import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
// import 'package:ecommerce_app/features/product/bloc/product_event.dart';
// import 'package:ecommerce_app/features/product/bloc/product_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:lottie/lottie.dart';

// class ProductWithTypePage extends StatefulWidget {
//   const ProductWithTypePage({super.key, required this.typeId, this.typeName});
//   final String typeId;
//   final String? typeName;
//   @override
//   State<ProductWithTypePage> createState() => _ProductWithTypePageState();
// }

// class _ProductWithTypePageState extends State<ProductWithTypePage> {
//   @override
//   void initState() {
//     super.initState();
//     // Gửi event để tải sản phẩm theo loại khi trang được khởi tạo
//     final typeId = int.tryParse(widget.typeId);
//     if (typeId != null) {
//       context.read<ProductBloc>().add(GetProductsByTypeEvent(typeId: typeId));
//     }
//   }

//   Future<void> _handleRefresh() async {
//     final typeId = int.tryParse(widget.typeId);
//     if (typeId != null) {
//       final bloc = context.read<ProductBloc>();
//       bloc.add(GetProductsByTypeEvent(typeId: typeId));
//       await bloc.stream
//           .firstWhere(
//             (state) => !state.isLoading,
//             orElse: () => bloc.state,
//           )
//           .timeout(const Duration(seconds: 10), onTimeout: () => bloc.state);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.typeName ?? 'Sản phẩm'),
//         centerTitle: true,
//       ),
//       body: RefreshIndicator(
//         onRefresh: _handleRefresh,
//         child: BlocBuilder<ProductBloc, ProductState>(
//           builder: (context, state) {
//             // Trạng thái đang tải
//             if (state.isLoading && state.products.isEmpty) {
//               return Center(
//                 child: Lottie.asset(
//                   "assets/lottie/loading_viemode.json",
//                   height: 100,
//                   width: 100,
//                 ),
//               );
//             }

//             // Trạng thái lỗi
//             if (state.hasError && state.products.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
//                     const SizedBox(height: 16),
//                     Text(
//                       "Không thể tải sản phẩm",
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleMedium
//                           ?.copyWith(color: Colors.grey[600]),
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       state.errorMessage ?? "Vui lòng thử lại sau",
//                       style: TextStyle(fontSize: 12, color: Colors.grey[500]),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 16),
//                     ElevatedButton.icon(
//                       onPressed: _handleRefresh,
//                       icon: const Icon(Icons.refresh),
//                       label: const Text('Thử lại'),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             // Không có sản phẩm
//             if (state.products.isEmpty) {
//               return Center(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(Icons.inventory_2_outlined,
//                         size: 64, color: Colors.grey[400]),
//                     const SizedBox(height: 16),
//                     Text(
//                       "Chưa có sản phẩm nào",
//                       style: Theme.of(context)
//                           .textTheme
//                           .titleMedium
//                           ?.copyWith(color: Colors.grey[600]),
//                     ),
//                   ],
//                 ),
//               );
//             }

//             // Hiển thị danh sách sản phẩm
//             return GridView.builder(
//               padding: const EdgeInsets.all(12.0),
//               itemCount: state.products.length,
//               gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                 crossAxisCount: 2,
//                 crossAxisSpacing: 12,
//                 mainAxisSpacing: 20,
//                 childAspectRatio: 0.55,
//               ),
//               itemBuilder: (context, index) {
//                 final product = state.products[index];
//                 return GestureDetector(
//                   onTap: () => print("Click Product ${product.name}"),
//                   child: ProductCard(product: product),
//                 );
//               },
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
import 'package:ecommerce_app/common_widgets/product_card.dart';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:ecommerce_app/features/product/data/models/brand_model.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/presentation/search_product_page.dart'
    show SortOption; // Tái sử dụng SortOption
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart'; // Sử dụng cho việc format tiền tệ
import 'package:lottie/lottie.dart';

// =========================================================================
// WIDGET CHÍNH
// =========================================================================

class ProductWithTypePage extends StatefulWidget {
  const ProductWithTypePage({super.key, required this.typeId, this.typeName});
  final String typeId;
  final String? typeName;
  @override
  State<ProductWithTypePage> createState() => _ProductWithTypePageState();
}

// =========================================================================
// LỚP FILTER
// =========================================================================

/// Định nghĩa lớp filter cho trang loại sản phẩm
class _ProductTypeFilter {
  final RangeValues? priceRange;
  final List<int> selectedBrandIds; // Lọc theo Brand
  final SortOption sortOption;

  const _ProductTypeFilter({
    this.priceRange,
    this.selectedBrandIds = const [],
    this.sortOption = SortOption.none,
  });

  _ProductTypeFilter copyWith({
    RangeValues? priceRange,
    List<int>? selectedBrandIds,
    SortOption? sortOption,
    bool clearPriceRange = false,
  }) {
    return _ProductTypeFilter(
      priceRange: clearPriceRange ? null : (priceRange ?? this.priceRange),
      selectedBrandIds: selectedBrandIds ?? this.selectedBrandIds,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  bool get isDefault =>
      priceRange == null &&
      selectedBrandIds.isEmpty &&
      sortOption == SortOption.none;

  int get activeFilterCount {
    int count = 0;
    if (priceRange != null) count++;
    if (selectedBrandIds.isNotEmpty) count++;
    if (sortOption != SortOption.none) count++;
    return count;
  }
}

// =========================================================================
// STATE CỦA TRANG
// =========================================================================

class _ProductWithTypePageState extends State<ProductWithTypePage> {
  _ProductTypeFilter _currentFilter = const _ProductTypeFilter();
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    final typeId = int.tryParse(widget.typeId);
    if (typeId != null) {
      context.read<ProductBloc>().add(GetProductsByTypeEvent(typeId: typeId));
    }
  }

  Future<void> _handleRefresh() async {
    _loadProducts();
  }

  /// Hàm tính giá sản phẩm
  double _getProductPrice(ProductModel product) {
    return (product.priceHistoryModel != null &&
            product.priceHistoryModel!.isNotEmpty)
        ? product.priceHistoryModel!.last.price.toDouble()
        : 0.0;
  }

  /// Hàm áp dụng bộ lọc và sắp xếp
  void _applyFiltersAndSort(List<ProductModel> allProducts) {
    List<ProductModel> filtered = List.from(allProducts);

    // Lọc theo thương hiệu
    if (_currentFilter.selectedBrandIds.isNotEmpty) {
      filtered = filtered
          .where((p) => _currentFilter.selectedBrandIds.contains(p.brand?.id))
          .toList();
    }

    // Lọc theo khoảng giá
    if (_currentFilter.priceRange != null) {
      filtered = filtered.where((product) {
        final price = _getProductPrice(product);
        return price >= _currentFilter.priceRange!.start &&
            price <= _currentFilter.priceRange!.end;
      }).toList();
    }

    // Sắp xếp
    switch (_currentFilter.sortOption) {
      case SortOption.priceAsc:
        filtered
            .sort((a, b) => _getProductPrice(a).compareTo(_getProductPrice(b)));
        break;
      case SortOption.priceDesc:
        filtered
            .sort((a, b) => _getProductPrice(b).compareTo(_getProductPrice(a)));
        break;
      case SortOption.nameAsc:
        filtered.sort((a, b) => a.name.compareTo(b.name));
        break;
      case SortOption.nameDesc:
        filtered.sort((a, b) => b.name.compareTo(a.name));
        break;
      case SortOption.newest:
        filtered.sort((a, b) => (b.createdAt ?? DateTime.now())
            .compareTo(a.createdAt ?? DateTime.now()));
        break;
      case SortOption.oldest:
        filtered.sort((a, b) => (a.createdAt ?? DateTime.now())
            .compareTo(b.createdAt ?? DateTime.now()));
        break;
      case SortOption.none:
        break;
    }

    // Chỉ cập nhật nếu danh sách thay đổi (để tránh build không cần thiết)
    setState(() {
      _filteredProducts = filtered;
    });
  }

  /// Hàm hiển thị Modal lọc
  void _showFilterModal(List<ProductModel> allProducts) {
    // Lấy danh sách thương hiệu duy nhất từ sản phẩm
    final availableBrands = allProducts
        .where((p) => p.brand != null)
        .map((p) => p.brand!)
        .toSet()
        .toList();
    print("Available Brands: $availableBrands");
    // Tính toán khoảng giá
    RangeValues priceRangeLimit = const RangeValues(0, 1000000);
    if (allProducts.isNotEmpty) {
      final prices =
          allProducts.map(_getProductPrice).where((p) => p > 0).toList();
      if (prices.isNotEmpty) {
        prices.sort();
        final minPrice = prices.first;
        final maxPrice = prices.last;

        // Logic làm tròn giá thông minh
        double roundTo = 10000;
        if (maxPrice > 10000000) {
          roundTo = 1000000;
        } else if (maxPrice > 1000000) {
          roundTo = 100000;
        } else if (maxPrice > 100000) {
          roundTo = 10000;
        } else {
          roundTo = 1000;
        }

        priceRangeLimit = RangeValues(
          (minPrice / roundTo).floor() * roundTo,
          (maxPrice / roundTo).ceil() * roundTo,
        );
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterBottomSheet(
        currentFilter: _currentFilter,
        availableBrands: availableBrands,
        priceRangeLimit: priceRangeLimit,
        productCount: allProducts.length,
        onFilterChanged: (newFilter) {
          setState(() => _currentFilter = newFilter);
          _applyFiltersAndSort(allProducts);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.typeName ?? 'Sản phẩm'),
        centerTitle: true,
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? "Đã xảy ra lỗi!")),
            );
          }
          // Áp dụng bộ lọc lần đầu sau khi tải xong dữ liệu
          if (state.products.isNotEmpty && !state.isLoading) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _applyFiltersAndSort(state.products);
            });
          }
        },
        builder: (context, state) {
          final allProducts = state.products;
          final displayProducts =
              _currentFilter.isDefault ? allProducts : _filteredProducts;

          if (state.isLoading && state.products.isEmpty) {
            return Center(
              child: Lottie.asset(
                "assets/lottie/loading_viemode.json",
                height: 100,
                width: 100,
              ),
            );
          }

          // Trạng thái lỗi
          if (state.hasError && state.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline,
                      size: 64, color: Theme.of(context).colorScheme.error),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? "Không thể tải sản phẩm",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _handleRefresh,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          // Không có sản phẩm
          if (state.products.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    "Chưa có sản phẩm nào",
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Hiển thị danh sách sản phẩm với Filter Bar cố định
          return RefreshIndicator(
            onRefresh: _handleRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                // Thanh lọc cố định khi cuộn
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FilterBarDelegate(this, allProducts),
                ),
                // Danh sách sản phẩm
                SliverPadding(
                  padding: const EdgeInsets.all(8.0),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12.0,
                      mainAxisSpacing: 20.0,
                      childAspectRatio: 0.55,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final product = displayProducts[index];
                        return GestureDetector(
                            onTap: () => print("Click Product ${product.name}"),
                            child: ProductCard(product: product));
                      },
                      childCount: displayProducts.length,
                    ),
                  ),
                ),
                // Loading indicator khi refresh
                SliverToBoxAdapter(
                  child: Visibility(
                    visible: state.isRefreshing && state.products.isNotEmpty,
                    child: const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// =========================================================================
// DELEGATE CHO FILTER BAR (THANH LỌC CỐ ĐỊNH)
// =========================================================================

class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final _ProductWithTypePageState _screenState;
  final List<ProductModel> _allProducts;

  _FilterBarDelegate(this._screenState, this._allProducts);

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    final filter = _screenState._currentFilter;
    final hasActiveFilters = !filter.isDefault;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Nút Lọc với badge
          Stack(
            clipBehavior: Clip.none,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: ElevatedButton.icon(
                  onPressed: () => _screenState._showFilterModal(_allProducts),
                  icon: const Icon(Icons.tune, size: 20),
                  label: const Text(
                    'Bộ lọc',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: hasActiveFilters
                        ? Theme.of(context).primaryColor
                        : Colors.grey[100],
                    foregroundColor:
                        hasActiveFilters ? Colors.white : Colors.black87,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),

              // Badge hiển thị số filter đang bật
              if (hasActiveFilters)
                Positioned(
                  right: -2,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Center(
                      child: Text(
                        '${filter.activeFilterCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),

          const SizedBox(width: 8),

          // Nút Sắp xếp
          PopupMenuButton<SortOption>(
            initialValue: filter.sortOption,
            onSelected: (option) {
              _screenState.setState(() {
                _screenState._currentFilter =
                    filter.copyWith(sortOption: option);
              });
              _screenState._applyFiltersAndSort(_allProducts);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: SortOption.none,
                child: Row(
                  children: [
                    Icon(Icons.clear, size: 16, color: Colors.grey),
                    SizedBox(width: 8),
                    Text('Mặc định'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: SortOption.priceAsc,
                child: Row(
                  children: [
                    Icon(Icons.arrow_upward,
                        size: 16, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text('Giá thấp → cao'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.priceDesc,
                child: Row(
                  children: [
                    Icon(Icons.arrow_downward,
                        size: 16, color: Colors.blueAccent),
                    SizedBox(width: 8),
                    Text('Giá cao → thấp'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: SortOption.nameAsc,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha,
                        size: 16, color: Colors.orangeAccent),
                    SizedBox(width: 8),
                    Text('Tên A → Z'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.nameDesc,
                child: Row(
                  children: [
                    Icon(Icons.sort_by_alpha,
                        size: 16, color: Colors.orangeAccent),
                    SizedBox(width: 8),
                    Text('Tên Z → A'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: SortOption.newest,
                child: Row(
                  children: [
                    Icon(Icons.fiber_new, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Mới nhất'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: SortOption.oldest,
                child: Row(
                  children: [
                    Icon(Icons.history, size: 16, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Cũ nhất'),
                  ],
                ),
              ),
            ],

            // Nút chính hiển thị
            child: ElevatedButton.icon(
              onPressed: null,
              icon: const Icon(Icons.sort, size: 18),
              label: Text(
                _getSortLabel(filter.sortOption),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey[100],
                disabledForegroundColor: Colors.black87,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: const BorderSide(color: Colors.black12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const Spacer(),

          // Số lượng sản phẩm hiển thị
          Text(
            '${_screenState._filteredProducts.isEmpty ? _allProducts.length : _screenState._filteredProducts.length} SP',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),

          // Nút xóa bộ lọc
          if (hasActiveFilters) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.clear, size: 20),
              onPressed: () {
                _screenState.setState(() {
                  _screenState._currentFilter = const _ProductTypeFilter();
                });
                _screenState._applyFiltersAndSort(_allProducts);
              },
              tooltip: 'Xóa bộ lọc',
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ],
      ),
    );
  }

  String _getSortLabel(SortOption option) {
    switch (option) {
      case SortOption.priceAsc:
        return 'Giá ↑';
      case SortOption.priceDesc:
        return 'Giá ↓';
      case SortOption.nameAsc:
        return 'Tên A-Z';
      case SortOption.nameDesc:
        return 'Tên Z-A';
      case SortOption.newest:
        return 'Mới nhất';
      case SortOption.oldest:
        return 'Cũ nhất';
      case SortOption.none:
        return 'Sắp xếp';
    }
  }

  @override
  double get maxExtent => 56.0;

  @override
  double get minExtent => 56.0;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => true;
}

// =========================================================================
// BOTTOM SHEET LỌC
// =========================================================================

class _FilterBottomSheet extends StatefulWidget {
  final _ProductTypeFilter currentFilter;
  final List<BrandModel> availableBrands; // Danh sách Brand
  final RangeValues priceRangeLimit;
  final int productCount;
  final Function(_ProductTypeFilter) onFilterChanged;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.availableBrands,
    required this.priceRangeLimit,
    required this.productCount,
    required this.onFilterChanged,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late _ProductTypeFilter _tempFilter;
  late RangeValues _tempPriceRange;
  bool _isPriceFilterActive = false;

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.currentFilter;
    _tempPriceRange = widget.currentFilter.priceRange ?? widget.priceRangeLimit;
    _isPriceFilterActive = widget.currentFilter.priceRange != null;
  }

  /// Hàm format giá ngắn gọn
  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(price % 1000000 == 0 ? 0 : 1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(price % 1000 == 0 ? 0 : 1)}K';
    }
    return price.toStringAsFixed(0);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header với drag handle
          Container(
            padding: const EdgeInsets.only(top: 8),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bộ lọc',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _tempFilter = const _ProductTypeFilter();
                            _tempPriceRange = widget.priceRangeLimit;
                            _isPriceFilterActive = false;
                          });
                        },
                        icon: const Icon(Icons.refresh, size: 18),
                        label: const Text('Đặt lại'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Nội dung lọc
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lọc theo Brand
                  if (widget.availableBrands.isNotEmpty) ...[
                    _buildBrandFilter(),
                    const SizedBox(height: 24),
                  ],
                  // Lọc theo Giá
                  _buildPriceFilter(),
                ],
              ),
            ),
          ),

          // Nút bấm Áp dụng
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2))
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Hủy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        // Áp dụng khoảng giá chỉ khi switch được bật
                        final finalFilter = _isPriceFilterActive
                            ? _tempFilter.copyWith(priceRange: _tempPriceRange)
                            : _tempFilter.copyWith(clearPriceRange: true);

                        widget.onFilterChanged(finalFilter);
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Áp dụng bộ lọc'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Widget lọc theo Brand
  Widget _buildBrandFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.business_outlined, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Thương hiệu',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (_tempFilter.selectedBrandIds.isNotEmpty)
              Text(
                '${_tempFilter.selectedBrandIds.length} đã chọn',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 150),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: widget.availableBrands.map((brand) {
                final isSelected =
                    _tempFilter.selectedBrandIds.contains(brand.id);
                return FilterChip(
                  label: Text(
                    brand.brandName,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      final brandIds =
                          List<int>.from(_tempFilter.selectedBrandIds);
                      if (selected) {
                        brandIds.add(brand.id);
                      } else {
                        brandIds.remove(brand.id);
                      }
                      _tempFilter =
                          _tempFilter.copyWith(selectedBrandIds: brandIds);
                    });
                  },
                  selectedColor:
                      Theme.of(context).primaryColor.withOpacity(0.2),
                  checkmarkColor: Theme.of(context).primaryColor,
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget lọc theo Khoảng giá
  Widget _buildPriceFilter() {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.payments_outlined, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Khoảng giá',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Switch(
              value: _isPriceFilterActive,
              onChanged: (value) {
                setState(() {
                  _isPriceFilterActive = value;
                  if (!value) {
                    _tempPriceRange = widget.priceRangeLimit;
                  }
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedOpacity(
          opacity: _isPriceFilterActive ? 1.0 : 0.4,
          duration: const Duration(milliseconds: 200),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Từ: ${_formatPrice(_tempPriceRange.start)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _isPriceFilterActive ? null : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Flexible(
                    child: Text(
                      'Đến: ${_formatPrice(_tempPriceRange.end)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: _isPriceFilterActive ? null : Colors.grey,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              RangeSlider(
                values: _tempPriceRange,
                min: widget.priceRangeLimit.start,
                max: widget.priceRangeLimit.end,
                divisions: 20,
                labels: RangeLabels(
                  _formatPrice(_tempPriceRange.start),
                  _formatPrice(_tempPriceRange.end),
                ),
                onChanged: _isPriceFilterActive
                    ? (values) {
                        setState(() {
                          _tempPriceRange = values;
                        });
                      }
                    : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isPriceFilterActive
                              ? Theme.of(context).primaryColor.withOpacity(0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giá tối thiểu',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormatter.format(_tempPriceRange.start),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _isPriceFilterActive ? null : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _isPriceFilterActive
                              ? Theme.of(context).primaryColor.withOpacity(0.3)
                              : Colors.transparent,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Giá tối đa',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            currencyFormatter.format(_tempPriceRange.end),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              color: _isPriceFilterActive ? null : Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
