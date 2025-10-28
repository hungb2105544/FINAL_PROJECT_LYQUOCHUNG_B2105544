import 'package:ecommerce_app/common_widgets/product_card.dart';
import 'package:ecommerce_app/features/product/bloc/favorite_bloc/favorite_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/favorite_bloc/favorite_event.dart';
import 'package:ecommerce_app/features/product/bloc/favorite_bloc/favorite_state.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart';

enum SortOption {
  none,
  priceAsc,
  priceDesc,
  nameAsc,
  nameDesc,
  newest,
  oldest,
}

/// Model cho filter
class ProductFilter {
  final List<String> selectedBrands;
  final RangeValues? priceRange;
  final SortOption sortOption;
  final bool inStockOnly;

  const ProductFilter({
    this.selectedBrands = const [],
    this.priceRange,
    this.sortOption = SortOption.none,
    this.inStockOnly = false,
  });

  ProductFilter copyWith({
    List<String>? selectedBrands,
    RangeValues? priceRange,
    SortOption? sortOption,
    bool? inStockOnly,
    bool clearPriceRange = false,
  }) {
    return ProductFilter(
      selectedBrands: selectedBrands ?? this.selectedBrands,
      priceRange: clearPriceRange ? null : (priceRange ?? this.priceRange),
      sortOption: sortOption ?? this.sortOption,
      inStockOnly: inStockOnly ?? this.inStockOnly,
    );
  }

  bool get isEmpty =>
      selectedBrands.isEmpty &&
      priceRange == null &&
      sortOption == SortOption.none &&
      !inStockOnly;

  int get activeFiltersCount {
    int count = 0;
    if (selectedBrands.isNotEmpty) count++;
    if (priceRange != null) count++;
    if (inStockOnly) count++;
    return count;
  }
}

class FavoriteSceen extends StatefulWidget {
  const FavoriteSceen({super.key});

  @override
  State<FavoriteSceen> createState() => _FavoriteSceenState();
}

class _FavoriteSceenState extends State<FavoriteSceen> {
  // Filter state
  ProductFilter _currentFilter = const ProductFilter();
  List<String> _availableBrands = [];
  RangeValues _priceRangeLimit = const RangeValues(0, 10000000);
  List<ProductModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    // Tải danh sách yêu thích khi màn hình được mở
    context.read<FavoriteBloc>().add(LoadFavorites());
  }

  Future<void> _onRefresh() async {
    context.read<FavoriteBloc>().add(LoadFavorites());
  }

  void _updateFilterData(List<ProductModel> products) {
    // Extract unique brands
    final brands = products
        .where(
            (p) => p.brand?.brandName != null && p.brand!.brandName.isNotEmpty)
        .map((p) => p.brand!.brandName)
        .toSet()
        .toList();
    brands.sort();

    // Calculate price range
    if (products.isNotEmpty) {
      final prices =
          products.map(_getProductPrice).where((p) => p > 0).toList();
      if (prices.isNotEmpty) {
        prices.sort();
        final minPrice = prices.first;
        final maxPrice = prices.last;
        _priceRangeLimit = RangeValues(
          (minPrice / 1000).floor() * 1000.0,
          (maxPrice / 1000).ceil() * 1000.0,
        );
      }
    }

    setState(() {
      _availableBrands = brands;
    });
  }

  double _getProductPrice(ProductModel product) {
    return (product.priceHistoryModel != null &&
            product.priceHistoryModel!.isNotEmpty)
        ? product.priceHistoryModel!.last.price.toDouble()
        : 0.0;
  }

  void _applyFilters(List<ProductModel> baseProducts) {
    List<ProductModel> filtered = List.from(baseProducts);

    // Filter by brands
    if (_currentFilter.selectedBrands.isNotEmpty) {
      filtered = filtered.where((product) {
        return _currentFilter.selectedBrands.contains(product.brand?.brandName);
      }).toList();
    }

    // Filter by price range
    if (_currentFilter.priceRange != null) {
      filtered = filtered.where((product) {
        final price = _getProductPrice(product);
        return price >= _currentFilter.priceRange!.start &&
            price <= _currentFilter.priceRange!.end;
      }).toList();
    }

    // Filter by stock
    if (_currentFilter.inStockOnly) {
      filtered = filtered.where((product) => product.isActive == true).toList();
    }

    // Apply sorting
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

    setState(() {
      _filteredProducts = filtered;
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterBottomSheet(
        currentFilter: _currentFilter,
        availableBrands: _availableBrands,
        priceRangeLimit: _priceRangeLimit,
        onFilterChanged: (newFilter) {
          setState(() => _currentFilter = newFilter);
          final state = context.read<FavoriteBloc>().state;
          _applyFilters(state.favoriteProducts);
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilter = const ProductFilter();
    });
    final state = context.read<FavoriteBloc>().state;
    _applyFilters(state.favoriteProducts);
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Filter button
          InkWell(
            onTap: _showFilterModal,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    _currentFilter.isEmpty ? Colors.grey[100] : Colors.blue[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _currentFilter.isEmpty
                      ? Colors.grey[300]!
                      : Colors.blue[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.filter_list,
                    size: 18,
                    color: _currentFilter.isEmpty
                        ? Colors.grey[600]
                        : Colors.blue[700],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Lọc',
                    style: TextStyle(
                      color: _currentFilter.isEmpty
                          ? Colors.grey[600]
                          : Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_currentFilter.activeFiltersCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.blue[700],
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${_currentFilter.activeFiltersCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Sort dropdown
          _buildSortDropdown(),

          const Spacer(),

          // Clear filters button
          if (!_currentFilter.isEmpty)
            TextButton(
              onPressed: _clearAllFilters,
              child: const Text('Xóa bộ lọc'),
            ),
        ],
      ),
    );
  }

  Widget _buildSortDropdown() {
    return PopupMenuButton<SortOption>(
      initialValue: _currentFilter.sortOption,
      onSelected: (SortOption option) {
        setState(() {
          _currentFilter = _currentFilter.copyWith(sortOption: option);
        });
        final state = context.read<FavoriteBloc>().state;
        _applyFilters(state.favoriteProducts);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: _currentFilter.sortOption != SortOption.none
              ? Colors.green[50]
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _currentFilter.sortOption != SortOption.none
                ? Colors.green[300]!
                : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.sort,
              size: 18,
              color: _currentFilter.sortOption != SortOption.none
                  ? Colors.green[700]
                  : Colors.grey[600],
            ),
            const SizedBox(width: 4),
            Text(
              'Sắp xếp',
              style: TextStyle(
                color: _currentFilter.sortOption != SortOption.none
                    ? Colors.green[700]
                    : Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: SortOption.none,
          child: Text('Mặc định'),
        ),
        const PopupMenuItem(
          value: SortOption.priceAsc,
          child: Text('Giá thấp đến cao'),
        ),
        const PopupMenuItem(
          value: SortOption.priceDesc,
          child: Text('Giá cao đến thấp'),
        ),
        const PopupMenuItem(
          value: SortOption.nameAsc,
          child: Text('Tên A-Z'),
        ),
        const PopupMenuItem(
          value: SortOption.nameDesc,
          child: Text('Tên Z-A'),
        ),
        const PopupMenuItem(
          value: SortOption.newest,
          child: Text('Mới nhất'),
        ),
        const PopupMenuItem(
          value: SortOption.oldest,
          child: Text('Cũ nhất'),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sản phẩm yêu thích'),
      ),
      body: BlocConsumer<FavoriteBloc, FavoriteState>(
        listener: (context, state) {
          if (!state.isLoading && state.favoriteProducts.isNotEmpty) {
            _updateFilterData(state.favoriteProducts);
            _applyFilters(state.favoriteProducts);
          }
        },
        builder: (context, state) {
          if (state.isLoading && state.favoriteProducts.isEmpty) {
            return Center(
              child: Lottie.asset(
                "assets/lottie/loading_viemode.json",
                height: 100,
                width: 100,
              ),
            );
          }

          if (state.error != null && state.favoriteProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Lỗi: ${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _onRefresh,
                    child: const Text('Thử lại'),
                  )
                ],
              ),
            );
          }

          if (state.favoriteProducts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Chưa có sản phẩm yêu thích nào',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          // Hiển thị danh sách đã lọc
          final displayProducts =
              _filteredProducts.isEmpty && !_currentFilter.isEmpty
                  ? []
                  : (_filteredProducts.isEmpty
                      ? state.favoriteProducts
                      : _filteredProducts);

          return Column(
            children: [
              // Filter Bar
              _buildFilterBar(),

              // Product count
              if (displayProducts.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        '${displayProducts.length} sản phẩm',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

              // Products Grid
              Expanded(
                child: displayProducts.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off,
                                size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            Text(
                              'Không tìm thấy sản phẩm nào',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Thử điều chỉnh bộ lọc',
                              style: TextStyle(color: Colors.grey[500]),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.55,
                          ),
                          itemCount: displayProducts.length,
                          itemBuilder: (context, index) {
                            final product = displayProducts[index];
                            return ProductCard(product: product);
                          },
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// Filter Bottom Sheet Widget
class _FilterBottomSheet extends StatefulWidget {
  final ProductFilter currentFilter;
  final List<String> availableBrands;
  final RangeValues priceRangeLimit;
  final Function(ProductFilter) onFilterChanged;

  const _FilterBottomSheet({
    required this.currentFilter,
    required this.availableBrands,
    required this.priceRangeLimit,
    required this.onFilterChanged,
  });

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late ProductFilter _tempFilter;
  late RangeValues _tempPriceRange;

  @override
  void initState() {
    super.initState();
    _tempFilter = widget.currentFilter;
    _tempPriceRange = widget.currentFilter.priceRange ?? widget.priceRangeLimit;
  }

  String _formatPrice(double price) {
    if (price >= 1000000) {
      return '${(price / 1000000).toStringAsFixed(1)}M';
    } else if (price >= 1000) {
      return '${(price / 1000).toStringAsFixed(0)}K';
    } else {
      return price.toStringAsFixed(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Bộ lọc',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _tempFilter = const ProductFilter();
                      _tempPriceRange = widget.priceRangeLimit;
                    });
                  },
                  child: const Text('Xóa tất cả'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Filter Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Brand Filter
                  _buildBrandFilter(),

                  const SizedBox(height: 24),

                  // Price Filter
                  _buildPriceFilter(),

                  const SizedBox(height: 24),

                  // Stock Filter
                  _buildStockFilter(),
                ],
              ),
            ),
          ),

          // Bottom buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Hủy'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // Apply price range if it's different from default
                      final finalFilter = (_tempPriceRange.start !=
                                  widget.priceRangeLimit.start ||
                              _tempPriceRange.end != widget.priceRangeLimit.end)
                          ? _tempFilter.copyWith(priceRange: _tempPriceRange)
                          : _tempFilter;

                      widget.onFilterChanged(finalFilter);
                      Navigator.pop(context);
                    },
                    child: const Text('Áp dụng'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandFilter() {
    if (widget.availableBrands.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thương hiệu',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.availableBrands.map((brand) {
            final isSelected = _tempFilter.selectedBrands.contains(brand);
            return FilterChip(
              label: Text(brand),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  final brands = List<String>.from(_tempFilter.selectedBrands);
                  if (selected) {
                    brands.add(brand);
                  } else {
                    brands.remove(brand);
                  }
                  _tempFilter = _tempFilter.copyWith(selectedBrands: brands);
                });
              },
              selectedColor: Colors.blue[100],
              checkmarkColor: Colors.blue[700],
              backgroundColor: Colors.grey[100],
              side: BorderSide(
                color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPriceFilter() {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    // Đảm bảo divisions > 0
    final divisions =
        (widget.priceRangeLimit.end - widget.priceRangeLimit.start > 0)
            ? 20
            : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Khoảng giá',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Text(
              'Từ ${_formatPrice(_tempPriceRange.start)} VND',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Text(
              'Đến ${_formatPrice(_tempPriceRange.end)} VND',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),

        const SizedBox(height: 8),

        RangeSlider(
          values: _tempPriceRange,
          min: widget.priceRangeLimit.start,
          max: widget.priceRangeLimit.end,
          divisions: divisions,
          labels: RangeLabels(
            _formatPrice(_tempPriceRange.start),
            _formatPrice(_tempPriceRange.end),
          ),
          onChanged: (values) {
            setState(() {
              _tempPriceRange = values;
            });
          },
          activeColor: Colors.orange,
          inactiveColor: Colors.orange[100],
        ),

        const SizedBox(height: 8),

        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giá tối thiểu',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(_tempPriceRange.start),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Giá tối đa',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormatter.format(_tempPriceRange.end),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Quick price ranges
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickPriceChip('Dưới 100K', 0, 100000),
            _buildQuickPriceChip('100K - 500K', 100000, 500000),
            _buildQuickPriceChip('500K - 1M', 500000, 1000000),
            _buildQuickPriceChip('1M - 5M', 1000000, 5000000),
            _buildQuickPriceChip(
                'Trên 5M', 5000000, widget.priceRangeLimit.end),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickPriceChip(String label, double min, double max) {
    final isSelected =
        _tempPriceRange.start == min && _tempPriceRange.end == max;

    return GestureDetector(
      onTap: () {
        setState(() {
          _tempPriceRange = RangeValues(
            min.clamp(widget.priceRangeLimit.start, widget.priceRangeLimit.end),
            max.clamp(widget.priceRangeLimit.start, widget.priceRangeLimit.end),
          );
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange[100] : Colors.grey[100],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.orange[300]! : Colors.grey[300]!,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isSelected ? Colors.orange[700] : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildStockFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tình trạng',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
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
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  children: [
                    Checkbox(
                      value: _tempFilter.inStockOnly,
                      onChanged: (value) {
                        setState(() {
                          _tempFilter =
                              _tempFilter.copyWith(inStockOnly: value);
                        });
                      },
                      activeColor: Colors.green,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chỉ hiển thị sản phẩm còn hàng',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
