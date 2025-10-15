import 'dart:async';
import 'package:ecommerce_app/features/product/bloc/poduct_bloc.dart';
import 'package:ecommerce_app/features/product/presentation/product_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:intl/intl.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';

class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 400});

  run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), () {
      if (action != null) {
        action();
      }
    });
  }

  void dispose() {
    _timer?.cancel();
  }
}

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

class ProductSearchPage extends StatefulWidget {
  const ProductSearchPage({super.key});

  @override
  State<ProductSearchPage> createState() => _ProductSearchPageState();
}

class _ProductSearchPageState extends State<ProductSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final Debouncer _debouncer = Debouncer(milliseconds: 400);
  final supabase = Supabase.instance.client;

  List<String> _searchSuggestions = [];
  List<ProductModel> _searchResults = [];
  List<ProductModel> _filteredResults = [];
  bool _isSearching = false;
  bool _showSuggestions = false;
  String _lastQuery = '';

  // Filter state
  ProductFilter _currentFilter = const ProductFilter();
  List<String> _availableBrands = [];
  RangeValues _priceRangeLimit = const RangeValues(0, 10000000);

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        setState(() => _showSuggestions = false);
      }
    });

    // Load initial products
    context.read<ProductBloc>().add(LoadProductsWithCache());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debouncer._timer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();

    if (query.isEmpty) {
      setState(() {
        _searchSuggestions = [];
        _showSuggestions = false;
        _searchResults = [];
      });
      _applyFilters();
      return;
    }

    setState(() => _showSuggestions = true);

    _debouncer.run(() {
      _fetchSearchSuggestions(query);
      _performSearch(query);
    });
  }

  Future<void> _fetchSearchSuggestions(String query) async {
    if (query.isEmpty) return;

    try {
      final response = await supabase
          .from('products')
          .select('name')
          .ilike('name', '%$query%')
          .limit(8);

      final results =
          (response as List).map((item) => item['name'] as String).toList();

      if (!mounted) return;
      setState(() => _searchSuggestions = results);
    } catch (e) {
      print('Error fetching suggestions: $e');
    }
  }

  void _performSearch(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      _applyFilters();
      return;
    }

    setState(() => _isSearching = true);
    _lastQuery = query;

    // Search trong products hiện có từ ProductBloc
    final currentProducts = context.read<ProductBloc>().state.products;
    final results = currentProducts
        .where((product) =>
            product.name.toLowerCase().contains(query.toLowerCase()) ||
            (product.description?.toLowerCase().contains(query.toLowerCase()) ??
                false))
        .toList();

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });

    _applyFilters();
  }

  void _applyFilters() {
    List<ProductModel> baseResults = _searchController.text.isEmpty
        ? context.read<ProductBloc>().state.products
        : _searchResults;

    List<ProductModel> filtered = List.from(baseResults);

    // Filter by brands
    if (_currentFilter.selectedBrands.isNotEmpty) {
      filtered = filtered.where((product) {
        return _currentFilter.selectedBrands.contains(product.brand!.brandName);
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
      _filteredResults = filtered;
    });
  }

  double _getProductPrice(ProductModel product) {
    return (product.priceHistoryModel != null &&
            product.priceHistoryModel!.isNotEmpty)
        ? product.priceHistoryModel!.last.price.toDouble()
        : 0.0;
  }

  void _updateFilterData(List<ProductModel> products) {
    // Extract unique brands
    final brands = products
        .where(
            (p) => p.brand!.brandName != null && p.brand!.brandName.isNotEmpty)
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

  void _selectSuggestion(String suggestion) {
    _searchController.text = suggestion;
    setState(() => _showSuggestions = false);
    _searchFocusNode.unfocus();
    _performSearch(suggestion);
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchSuggestions = [];
      _searchResults = [];
      _showSuggestions = false;
    });
    _applyFilters();
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
          _applyFilters();
        },
      ),
    );
  }

  void _clearAllFilters() {
    setState(() {
      _currentFilter = const ProductFilter();
    });
    _applyFilters();
  }

  TextSpan _highlightMatch(String text, String query) {
    if (query.isEmpty) {
      return TextSpan(
          text: text, style: const TextStyle(color: Colors.black87));
    }

    final lcText = text.toLowerCase();
    final lcQuery = query.toLowerCase();
    final startIndex = lcText.indexOf(lcQuery);

    if (startIndex == -1) {
      return TextSpan(
          text: text, style: const TextStyle(color: Colors.black87));
    }

    final before = text.substring(0, startIndex);
    final match = text.substring(startIndex, startIndex + query.length);
    final after = text.substring(startIndex + query.length);

    return TextSpan(
      children: [
        TextSpan(text: before, style: const TextStyle(color: Colors.black87)),
        TextSpan(
          text: match,
          style: TextStyle(
            color: Colors.orange,
            fontWeight: FontWeight.bold,
            background: Paint()..color = Colors.orange[100]!,
          ),
        ),
        TextSpan(text: after, style: const TextStyle(color: Colors.black87)),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: "Tìm kiếm sản phẩm...",
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: Icon(Icons.search, color: Colors.grey[400]),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.clear, color: Colors.grey[400]),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.grey[50],
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
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
        _applyFilters();
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

  Widget _buildSearchSuggestions() {
    if (!_showSuggestions || _searchSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: _searchSuggestions.map((suggestion) {
            return ListTile(
              dense: true,
              leading: Icon(Icons.search, color: Colors.grey[400], size: 20),
              title: RichText(
                text: _highlightMatch(suggestion, _searchController.text),
              ),
              onTap: () => _selectSuggestion(suggestion),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: CircularProgressIndicator(),
        ),
      );
    }

    final displayResults =
        _searchController.text.isEmpty ? _filteredResults : _filteredResults;

    if (_searchController.text.isNotEmpty && displayResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy sản phẩm nào',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Thử điều chỉnh bộ lọc hoặc từ khóa khác',
              style: TextStyle(color: Colors.grey[500]),
            ),
          ],
        ),
      );
    }

    if (_searchController.text.isEmpty) {
      return _buildAllProducts();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Kết quả tìm kiếm "${_lastQuery}" (${displayResults.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: displayResults.length,
            itemBuilder: (context, index) {
              return _buildProductCard(displayResults[index]);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildAllProducts() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        // Update filter data when products change
        if (state.products.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return; // thêm dòng này
            _updateFilterData(state.products);
            if (_filteredResults.isEmpty && _currentFilter.isEmpty) {
              setState(() {
                _filteredResults = state.products;
              });
            }
          });
        }

        if (state.isLoading && state.products.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.hasError && state.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                const SizedBox(height: 16),
                Text(
                  'Có lỗi xảy ra',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  state.errorMessage ?? 'Vui lòng thử lại',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    context.read<ProductBloc>().add(LoadProductsWithCache());
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        if (state.products.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.inventory_2_outlined,
                    size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Chưa có sản phẩm nào',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        final displayProducts =
            _filteredResults.isEmpty ? state.products : _filteredResults;

        return RefreshIndicator(
          onRefresh: () async {
            context.read<ProductBloc>().add(RefreshProducts());
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Text(
                      'Sản phẩm (${displayProducts.length}/${state.products.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    if (state.isFromCache)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'Cache',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: displayProducts.length,
                  itemBuilder: (context, index) {
                    return _buildProductCard(displayProducts[index]);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(ProductModel product) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

    return Stack(
      children: [
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProductDetailPage(
                      product: product,
                    ),
                  ));
            },
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Product Image Placeholder
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        product.imageUrls?.isNotEmpty == true
                            ? product.imageUrls!.first
                            : 'https://via.placeholder.com/80x80.png?text=No+Image',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(Icons.broken_image,
                              color: Colors.grey[400]);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Product Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                          text: _highlightMatch(
                              product.name, _searchController.text),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (product.brand!.brandName != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            product.brand!.brandName ?? '',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              currencyFormatter.format(
                                  (product.priceHistoryModel != null &&
                                          product.priceHistoryModel!.isNotEmpty)
                                      ? product.priceHistoryModel!.last.price
                                      : 0),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: product.isActive == true
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.grey.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                product.isActive == true
                                    ? 'Còn hàng'
                                    : 'Hết hàng',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: product.isActive == true
                                      ? Colors.green[700]
                                      : Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (product.discounts != null && product.discounts!.isNotEmpty)
          Positioned(
            top: 1,
            left: 5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '-${product.discounts!.first.discountPercentage}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildSearchBar(),
                _buildSearchSuggestions(),
              ],
            ),
          ),

          // Filter Bar
          Container(
            color: Colors.white,
            child: Column(
              children: [
                _buildFilterBar(),
                Container(
                  height: 1,
                  color: Colors.grey[200],
                ),
              ],
            ),
          ),

          // Results Section
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
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
          divisions: 20,
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
        SwitchListTile(
          title: const Text('Chỉ hiển thị sản phẩm còn hàng'),
          subtitle: Text(
            'Ẩn những sản phẩm hết hàng',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          value: _tempFilter.inStockOnly,
          onChanged: (value) {
            setState(() {
              _tempFilter = _tempFilter.copyWith(inStockOnly: value);
            });
          },
          activeColor: Colors.green,
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }
}
