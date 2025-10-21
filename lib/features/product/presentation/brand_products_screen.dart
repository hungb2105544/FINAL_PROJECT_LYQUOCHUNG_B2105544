import 'package:ecommerce_app/common_widgets/product_card.dart';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:ecommerce_app/features/product/data/models/brand_model.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/data/models/product_type_model.dart';
import 'package:ecommerce_app/features/product/presentation/search_product_page.dart'
    show SortOption;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class BrandProductsScreen extends StatefulWidget {
  final BrandModel brand;

  const BrandProductsScreen({Key? key, required this.brand}) : super(key: key);

  @override
  State<BrandProductsScreen> createState() => _BrandProductsScreenState();
}

class _BrandProductFilter {
  final RangeValues? priceRange;
  final List<int> selectedProductTypeIds;
  final SortOption sortOption;

  const _BrandProductFilter({
    this.priceRange,
    this.selectedProductTypeIds = const [],
    this.sortOption = SortOption.none,
  });

  _BrandProductFilter copyWith({
    RangeValues? priceRange,
    List<int>? selectedProductTypeIds,
    SortOption? sortOption,
    bool clearPriceRange = false,
  }) {
    return _BrandProductFilter(
      priceRange: clearPriceRange ? null : (priceRange ?? this.priceRange),
      selectedProductTypeIds:
          selectedProductTypeIds ?? this.selectedProductTypeIds,
      sortOption: sortOption ?? this.sortOption,
    );
  }

  bool get isDefault =>
      priceRange == null &&
      selectedProductTypeIds.isEmpty &&
      sortOption == SortOption.none;

  int get activeFilterCount {
    int count = 0;
    if (priceRange != null) count++;
    if (selectedProductTypeIds.isNotEmpty) count++;
    if (sortOption != SortOption.none) count++;
    return count;
  }
}

class _BrandProductsScreenState extends State<BrandProductsScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshKey =
      GlobalKey<RefreshIndicatorState>();

  _BrandProductFilter _currentFilter = const _BrandProductFilter();
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  void _loadProducts() {
    context.read<ProductBloc>().add(
          GetProductsByBrandEvent(brandId: widget.brand.id),
        );
  }

  Future<void> _onRefresh() async {
    _loadProducts();
  }

  void _applyFiltersAndSort(List<ProductModel> allProducts) {
    List<ProductModel> filtered = List.from(allProducts);

    // Lọc theo loại sản phẩm
    if (_currentFilter.selectedProductTypeIds.isNotEmpty) {
      filtered = filtered
          .where(
              (p) => _currentFilter.selectedProductTypeIds.contains(p.type?.id))
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

    // Chỉ cập nhật nếu danh sách thay đổi
    if (_filteredProducts != filtered) {
      setState(() {
        _filteredProducts = filtered;
      });
    }
  }

  double _getProductPrice(ProductModel product) {
    return (product.priceHistoryModel != null &&
            product.priceHistoryModel!.isNotEmpty)
        ? product.priceHistoryModel!.last.price.toDouble()
        : 0.0;
  }

  void _showFilterModal(List<ProductModel> allProducts) {
    // Lấy danh sách loại sản phẩm duy nhất từ sản phẩm của brand
    final productTypes = allProducts
        .where((p) => p.type != null)
        .map((p) => p.type!)
        .toSet()
        .toList();
    print(productTypes.toString());
    // Tính toán khoảng giá với làm tròn thông minh
    RangeValues priceRangeLimit = const RangeValues(0, 1000000);
    if (allProducts.isNotEmpty) {
      final prices =
          allProducts.map(_getProductPrice).where((p) => p > 0).toList();
      if (prices.isNotEmpty) {
        prices.sort();
        final minPrice = prices.first;
        final maxPrice = prices.last;

        // Làm tròn thông minh dựa trên khoảng giá
        double roundTo = 10000; // Mặc định làm tròn đến 10k
        if (maxPrice > 10000000) {
          roundTo = 1000000; // Làm tròn đến 1M nếu giá > 10M
        } else if (maxPrice > 1000000) {
          roundTo = 100000; // Làm tròn đến 100k nếu giá > 1M
        } else if (maxPrice > 100000) {
          roundTo = 10000; // Làm tròn đến 10k nếu giá > 100k
        } else {
          roundTo = 1000; // Làm tròn đến 1k cho giá nhỏ
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
        availableProductTypes: productTypes,
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
        title: Text(widget.brand.brandName),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? "Đã xảy ra lỗi!")),
            );
          }
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
            return const Center(child: CircularProgressIndicator());
          }

          if (state.products.isEmpty &&
              !state.isLoading &&
              !state.isRefreshing) {
            return RefreshIndicator(
              key: _refreshKey,
              onRefresh: _onRefresh,
              child: ListView(
                children: [
                  _BrandHeaderSection(brand: widget.brand),
                  _BrandDescriptionSection(brand: widget.brand),
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.inventory_2_outlined,
                            size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Hiện tại chưa có sản phẩm nào của ${widget.brand.brandName}',
                          textAlign: TextAlign.center,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          if (allProducts.isEmpty) {
            return const Center(
                child: Text("Thương hiệu này chưa có sản phẩm."));
          }

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: _BrandHeaderSection(brand: widget.brand),
                ),
                SliverToBoxAdapter(
                  child: _BrandDescriptionSection(brand: widget.brand),
                ),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _FilterBarDelegate(this, allProducts),
                ),
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
                        return ProductCard(product: product);
                      },
                      childCount: displayProducts.length,
                    ),
                  ),
                ),
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
// DELEGATE CHO FILTER BAR
// =========================================================================
class _FilterBarDelegate extends SliverPersistentHeaderDelegate {
  final _BrandProductsScreenState _screenState;
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
              // ✅ Thêm padding bên phải để tránh bị che chữ
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

              // 🔴 Badge hiển thị số filter đang bật
              if (hasActiveFilters)
                Positioned(
                  right: -2, // Dịch nhẹ ra ngoài để không đè chữ
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
          // PopupMenuButton<SortOption>(
          //   initialValue: filter.sortOption,
          //   onSelected: (option) {
          //     _screenState.setState(() {
          //       _screenState._currentFilter =
          //           filter.copyWith(sortOption: option);
          //     });
          //     _screenState._applyFiltersAndSort(_allProducts);
          //   },
          //   itemBuilder: (context) => [
          //     const PopupMenuItem(
          //         value: SortOption.none, child: Text('Mặc định')),
          //     const PopupMenuDivider(),
          //     const PopupMenuItem(
          //         value: SortOption.priceAsc,
          //         child: Row(
          //           children: [
          //             Icon(Icons.arrow_upward, size: 16),
          //             SizedBox(width: 8),
          //             Text('Giá thấp → cao'),
          //           ],
          //         )),
          //     const PopupMenuItem(
          //         value: SortOption.priceDesc,
          //         child: Row(
          //           children: [
          //             Icon(Icons.arrow_downward, size: 16),
          //             SizedBox(width: 8),
          //             Text('Giá cao → thấp'),
          //           ],
          //         )),
          //     const PopupMenuDivider(),
          //     const PopupMenuItem(
          //         value: SortOption.nameAsc, child: Text('Tên A → Z')),
          //     const PopupMenuItem(
          //         value: SortOption.nameDesc, child: Text('Tên Z → A')),
          //     const PopupMenuDivider(),
          //     const PopupMenuItem(
          //         value: SortOption.newest,
          //         child: Row(
          //           children: [
          //             Icon(Icons.new_releases, size: 16),
          //             SizedBox(width: 8),
          //             Text('Mới nhất'),
          //           ],
          //         )),
          //     const PopupMenuItem(
          //         value: SortOption.oldest, child: Text('Cũ nhất')),
          //   ],
          //   child: ElevatedButton.icon(
          //     onPressed: null,
          //     icon: const Icon(Icons.sort, size: 18),
          //     label: Text(_getSortLabel(filter.sortOption)),
          //     style: ElevatedButton.styleFrom(
          //       disabledBackgroundColor:
          //           Theme.of(context).buttonTheme.colorScheme?.surface,
          //       disabledForegroundColor:
          //           Theme.of(context).buttonTheme.colorScheme?.onSurface,
          //     ),
          //   ),
          // ),
          PopupMenuButton<SortOption>(
            initialValue: filter.sortOption,
            onSelected: (option) {
              _screenState.setState(() {
                _screenState._currentFilter =
                    filter.copyWith(sortOption: option);
              });
              _screenState._applyFiltersAndSort(_allProducts);
            },
            // ✅ Menu đẹp và dễ đọc
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

            // ✅ Nút chính hiển thị (đẹp, đồng bộ với nút “Bộ lọc”)
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
                  _screenState._currentFilter = const _BrandProductFilter();
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
  final _BrandProductFilter currentFilter;
  final List<ProductTypeModel> availableProductTypes;
  final RangeValues priceRangeLimit;
  final int productCount;
  final Function(_BrandProductFilter) onFilterChanged;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.availableProductTypes,
    required this.priceRangeLimit,
    required this.productCount,
    required this.onFilterChanged,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late _BrandProductFilter _tempFilter;
  late RangeValues _tempPriceRange;
  bool _isPriceFilterActive = false;

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.currentFilter;
    _tempPriceRange = widget.currentFilter.priceRange ?? widget.priceRangeLimit;
    _isPriceFilterActive = widget.currentFilter.priceRange != null;
  }

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
                            _tempFilter = const _BrandProductFilter();
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
                  if (widget.availableProductTypes.isNotEmpty) ...[
                    _buildProductTypeFilter(),
                    const SizedBox(height: 24),
                  ],
                  _buildPriceFilter(),
                ],
              ),
            ),
          ),

          // Nút bấm
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

  Widget _buildProductTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.category, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Loại sản phẩm',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            if (_tempFilter.selectedProductTypeIds.isNotEmpty)
              Text(
                '${_tempFilter.selectedProductTypeIds.length} đã chọn',
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
              children: widget.availableProductTypes.map((type) {
                final isSelected =
                    _tempFilter.selectedProductTypeIds.contains(type.id);
                return FilterChip(
                  label: Text(
                    type.typeName,
                    overflow: TextOverflow.ellipsis,
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      final typeIds =
                          List<int>.from(_tempFilter.selectedProductTypeIds);
                      if (selected) {
                        typeIds.add(type.id);
                      } else {
                        typeIds.remove(type.id);
                      }
                      _tempFilter =
                          _tempFilter.copyWith(selectedProductTypeIds: typeIds);
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

// =========================================================================
// BRAND HEADER SECTION
// =========================================================================
class _BrandHeaderSection extends StatelessWidget {
  final BrandModel brand;
  const _BrandHeaderSection({required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo Brand với shadow
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.0),
              child: brand.imageUrl != null && brand.imageUrl!.isNotEmpty
                  ? Image.network(
                      brand.imageUrl!,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.business,
                            size: 40, color: Colors.grey),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.business,
                          size: 40, color: Colors.grey),
                    ),
            ),
          ),
          const SizedBox(width: 16),

          // Tên Brand
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  brand.brandName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.verified, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        'Thương hiệu chính hãng',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =========================================================================
// BRAND DESCRIPTION SECTION
// =========================================================================
class _BrandDescriptionSection extends StatefulWidget {
  final BrandModel brand;
  const _BrandDescriptionSection({required this.brand});

  @override
  State<_BrandDescriptionSection> createState() =>
      _BrandDescriptionSectionState();
}

class _BrandDescriptionSectionState extends State<_BrandDescriptionSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.brand.description == null || widget.brand.description!.isEmpty) {
      return const SizedBox(height: 8);
    }

    final description = widget.brand.description!;
    final shouldShowButton = description.length > 150;

    return Container(
      padding: const EdgeInsets.all(16.0),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.info_outline, size: 18, color: Colors.grey[700]),
              const SizedBox(width: 6),
              Text(
                'Giới thiệu thương hiệu',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          AnimatedCrossFade(
            firstChild: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.5,
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
          if (shouldShowButton)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
                icon: Icon(
                  _isExpanded ? Icons.expand_less : Icons.expand_more,
                  size: 18,
                ),
                label: Text(_isExpanded ? 'Thu gọn' : 'Xem thêm'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
