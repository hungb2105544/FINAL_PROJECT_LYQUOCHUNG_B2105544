import 'dart:async';
import 'package:ecommerce_app/features/product/domain/usecase/get_product_by_type.dart';
import 'package:ecommerce_app/features/product/domain/usecase/get_products_is_active.dart';
import 'package:ecommerce_app/features/product/domain/usecase/search_products.dart';
import 'package:ecommerce_app/features/product/domain/usecase/get_product_by_brand.dart';

import 'package:ecommerce_app/service/cache_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsIsActive _getProductsIsActiveUseCase;
  final GetProductByType _getProductsByTypeUseCase;
  final GetProductByBrand _getProductsByBrandUseCase;
  final SearchProducts _searchProductsUseCase;
  final CacheService _cacheService = CacheService();
  final SupabaseClient _supabase = Supabase.instance.client;

  Box<ProductModel> get _productsBox =>
      Hive.box<ProductModel>('products_cache');
  Box get _metadataBox => Hive.box('cache_metadata');

  RealtimeChannel? _productChannel;
  RealtimeChannel? _discountChannel;

  Timer? _realtimeDebounce;
  Timer? _discountDebounce;

  ProductBloc({
    required GetProductsIsActive getProductsIsActiveUseCase,
    required GetProductByType getProductsByTypeUseCase,
    required SearchProducts searchProductsUseCase,
    required GetProductByBrand getProductsByBrandUseCase,
  })  : _getProductsIsActiveUseCase = getProductsIsActiveUseCase,
        _getProductsByTypeUseCase = getProductsByTypeUseCase,
        _searchProductsUseCase = searchProductsUseCase,
        _getProductsByBrandUseCase = getProductsByBrandUseCase,
        super(const ProductState()) {
    on<GetProductIsActive>(_getProducts);
    on<LoadProductsFromCache>(_loadProductsFromCache);
    on<RefreshProducts>(_refreshProducts);
    on<LoadProductsWithCache>(_loadProductsWithCache);
    on<ClearProductsCache>(_clearProductsCache);
    on<LoadMoreProducts>(_loadMoreProducts);
    on<GetProductsByTypeEvent>(_getProductByTypeId);
    on<SearchProductsEvent>(_onSearchProducts);
    on<GetProductsByBrandEvent>(_getProductByBrandId);
    on<LoadProductsServerFirst>(_loadProductsServerFirst);
    print('🚀🚀🚀 ProductBloc initialized, setting up realtime...');
    _setupRealtimeSubscriptions();
  }

  Future<void> _loadProductsServerFirst(
    LoadProductsServerFirst event,
    Emitter<ProductState> emit,
  ) async {
    try {
      print('\n🌐 ════════════════════════════════════════');
      print('🌐 LOAD PRODUCTS - SERVER FIRST STRATEGY');
      print('🌐 ════════════════════════════════════════');

      // 🔵 Step 1: Emit loading state
      emit(state.copyWith(
        isLoading: true,
        isRefreshing: false,
        errorMessage: null,
        dataSource: DataSource.none,
      ));
      print('📤 Emitted: isLoading = true');

      // 🔵 Step 2: Fetch từ server TRƯỚC
      print(
          '🌍 Fetching from server (page: ${event.page}, limit: ${event.limit})...');
      final freshProducts = await _getProductsIsActiveUseCase.call(
        page: event.page,
        limit: event.limit,
        forceRefresh: true,
      );

      if (freshProducts.isNotEmpty) {
        print('✅ Received ${freshProducts.length} products from server');

        // 🔵 Step 3: Cập nhật cache
        print('💾 Updating cache...');
        await _cacheProducts(freshProducts, event.page, event.limit);
        print('✅ Cache updated successfully');

        // 🔵 Step 4: Emit fresh data
        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          products: freshProducts.toSet().toList(),
          errorMessage: null,
          dataSource: DataSource.server,
          lastUpdated: DateTime.now(),
          currentPage: event.page,
          hasReachedMax: freshProducts.length < event.limit,
        ));

        print('✅ UI updated with fresh data from server');
        print('🌐 ════════════════════════════════════════\n');
      } else {
        print('⚠️ Server returned empty data');
        if (event.useCacheFallback) {
          print('🔄 Attempting cache fallback...');
          await _fallbackToCache(event.page, event.limit, emit);
        } else {
          emit(state.copyWith(
            isLoading: false,
            isRefreshing: false,
            products: [],
            errorMessage: "Không có dữ liệu sản phẩm",
            dataSource: DataSource.none,
          ));
          print('❌ No fallback allowed, emitted empty state');
        }
        print('🌐 ════════════════════════════════════════\n');
      }
    } catch (error) {
      print('❌ ERROR: $error');

      if (event.useCacheFallback) {
        print('🔄 Server failed, attempting cache fallback...');
        await _fallbackToCache(event.page, event.limit, emit);
      } else {
        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: error.toString(),
          dataSource: DataSource.none,
        ));
        print('❌ No fallback allowed, emitted error state');
      }
      print('🌐 ════════════════════════════════════════\n');
    }
  }

  Future<void> _fallbackToCache(
    int page,
    int limit,
    Emitter<ProductState> emit,
  ) async {
    try {
      final cachedProducts = await _loadCachedProducts(
        page: page,
        limit: limit,
      );

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        print('✅ Found ${cachedProducts.length} products in cache');

        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          products: cachedProducts,
          errorMessage: "Không thể kết nối server, hiển thị dữ liệu đã lưu",
          dataSource: DataSource.cache,
          currentPage: page,
          hasReachedMax: false,
        ));

        print('✅ UI updated with cached data (fallback)');
      } else {
        print('❌ No cache available for fallback');

        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          products: [],
          errorMessage: "Không có kết nối internet và không có dữ liệu đã lưu",
          dataSource: DataSource.none,
        ));
      }
    } catch (cacheError) {
      print('❌ Cache fallback also failed: $cacheError');

      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: "Không thể tải dữ liệu",
        dataSource: DataSource.none,
      ));
    }
  }

  void _setupRealtimeSubscriptions() {
    print('═══════════════════════════════════════');
    print('🔧 SETTING UP REALTIME SUBSCRIPTIONS');
    print('═══════════════════════════════════════');
    _setupProductChannel();
    _setupDiscountChannel();
    print('✅ Setup completed');
    print('═══════════════════════════════════════\n');
  }

  void _setupProductChannel() {
    print('\n📦 ━━━ PRODUCTS CHANNEL SETUP ━━━');
    _productChannel?.unsubscribe();

    final channelName =
        'products_changes_${DateTime.now().millisecondsSinceEpoch}';
    print('   Channel name: $channelName');

    _productChannel = _supabase
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            print('\n┌─────────────────────────────────────┐');
            print('│  📡 PRODUCTS EVENT RECEIVED!        │');
            print('└─────────────────────────────────────┘');
            print('Event Type: ${payload.eventType}');
            print('New Record: ${payload.newRecord}');
            print('Old Record: ${payload.oldRecord}');
            print('─────────────────────────────────────\n');

            _realtimeDebounce?.cancel();
            _realtimeDebounce = Timer(const Duration(seconds: 2), () {
              print('⏰ Products debounce timer triggered');
              _handleProductRefresh();
            });
          },
        )
        .subscribe((status, [error]) {
      print('🔔 Products Status: $status');
      if (status == RealtimeSubscribeStatus.subscribed) {
        print('   ✅ PRODUCTS SUCCESSFULLY SUBSCRIBED!');
      } else if (status == RealtimeSubscribeStatus.channelError) {
        print('   ❌ PRODUCTS CHANNEL ERROR!');
      } else if (status == RealtimeSubscribeStatus.timedOut) {
        print('   ⏱️ PRODUCTS TIMED OUT!');
      }
      if (error != null) print('   ⚠️ Error: $error');
    });
  }

  void _setupDiscountChannel() {
    print('\n💰 ━━━ DISCOUNTS CHANNEL SETUP ━━━');
    _discountChannel?.unsubscribe();

    final channelName =
        'discounts_changes_${DateTime.now().millisecondsSinceEpoch}';
    print('   Channel name: $channelName');

    _discountChannel = _supabase
        .channel(channelName)
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'product_discounts',
          callback: (payload) {
            print('\n┌─────────────────────────────────────┐');
            print('│  💰 DISCOUNTS EVENT RECEIVED!       │');
            print('└─────────────────────────────────────┘');
            print('Event Type: ${payload.eventType}');
            print('New Record: ${payload.newRecord}');
            print('Old Record: ${payload.oldRecord}');
            print('─────────────────────────────────────\n');
            print('📤 Emitting isRefreshing: true');
            emit(state.copyWith(
              isRefreshing: true,
              errorMessage: null,
            ));

            _discountDebounce?.cancel();
            _discountDebounce = Timer(const Duration(seconds: 2), () {
              print('⏰ Discounts debounce timer triggered');
              _handleDiscountRefresh();
            });
          },
        )
        .subscribe((status, [error]) {
      print('🔔 Discounts Status: $status');
      if (status == RealtimeSubscribeStatus.subscribed) {
        print('   ✅ DISCOUNTS SUCCESSFULLY SUBSCRIBED!');
      } else if (status == RealtimeSubscribeStatus.channelError) {
        print('   ❌ DISCOUNTS CHANNEL ERROR!');
      } else if (status == RealtimeSubscribeStatus.timedOut) {
        print('   ⏱️ DISCOUNTS TIMED OUT!');
      }
      if (error != null) print('   ⚠️ Error: $error');
    });
  }

  Future<void> _handleProductRefresh() async {
    try {
      print('\n🔄 ━━━ PRODUCTS REFRESH STARTED ━━━');

      emit(state.copyWith(
        isRefreshing: true,
        errorMessage: null,
      ));
      print('✅ Emitted isRefreshing: true');

      final currentPage = state.currentPage;
      final currentLimit = 20;

      print(
          '📥 Fetching products (page: $currentPage, limit: $currentLimit)...');
      final freshProducts = await _getProductsIsActiveUseCase.call(
        page: currentPage,
        limit: currentLimit,
        forceRefresh: true,
      );
      print('📦 Received ${freshProducts.length} products');

      if (freshProducts.isNotEmpty) {
        await _cacheProducts(freshProducts, currentPage, currentLimit);

        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          products: freshProducts.toSet().toList(),
          errorMessage: null,
          dataSource: DataSource.server,
          lastUpdated: DateTime.now(),
          hasReachedMax: freshProducts.length < currentLimit,
        ));

        print('✅ Products updated successfully');
        print('━━━ PRODUCTS REFRESH COMPLETED ━━━\n');
      } else {
        emit(state.copyWith(
          isRefreshing: false,
          errorMessage: 'Không có dữ liệu từ server',
        ));
        print('⚠️ No products received from server');
      }
    } catch (e) {
      print('❌ Products refresh error: $e');
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: 'Lỗi cập nhật sản phẩm: $e',
      ));
    }
  }

  Future<void> _handleDiscountRefresh() async {
    try {
      print('\n🔄 ━━━ DISCOUNTS REFRESH STARTED ━━━');

      // Đảm bảo state được emit
      print('📤 Emitting isRefreshing: true');
      emit(state.copyWith(
        isRefreshing: true,
        errorMessage: null,
      ));

      final currentPage = state.currentPage;
      final currentLimit = 20;

      print(
          '📥 Fetching products (page: $currentPage, limit: $currentLimit)...');
      final freshProducts = await _getProductsIsActiveUseCase.call(
        page: currentPage,
        limit: currentLimit,
        forceRefresh: true,
      );
      print('📦 Received ${freshProducts.length} products');

      if (freshProducts.isNotEmpty) {
        await _cacheProducts(freshProducts, currentPage, currentLimit);

        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          products: freshProducts.toSet().toList(),
          errorMessage: null,
          dataSource: DataSource.server,
          lastUpdated: DateTime.now(),
          hasReachedMax: freshProducts.length < currentLimit,
        ));

        print(
            '✅ Discounts refresh completed, products updated: ${freshProducts.length}');
        print('━━━ DISCOUNTS REFRESH COMPLETED ━━━\n');
      }
    } catch (e) {
      print('❌ Discounts refresh error: $e');
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: 'Lỗi cập nhật giá khuyến mãi: $e',
      ));
    }
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      emit(state.copyWith(
        searchResults: [],
        isSearching: false,
        errorMessage: null,
      ));
      return;
    }

    try {
      emit(state.copyWith(isSearching: true, errorMessage: null));

      final products = await _searchProductsUseCase.call(event.query.trim());

      emit(state.copyWith(
        isSearching: false,
        searchResults: products,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isSearching: false,
        searchResults: [],
        errorMessage: "Lỗi khi tìm kiếm: ${e.toString()}",
      ));
    }
  }

  Future<void> _getProductByTypeId(
    GetProductsByTypeEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        isRefreshing: false,
        errorMessage: null,
      ));

      final cachedProducts =
          await _loadCachedProductsForType(event.typeId.toString());
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        emit(state.copyWith(
          isLoading: false,
          isRefreshing: true,
          products: cachedProducts,
          dataSource: DataSource.cache,
          currentPage: 1,
          hasReachedMax: false,
        ));
      }

      final products =
          await _getProductsByTypeUseCase.call(event.typeId.toString());

      await _cacheProductsForType(event.typeId.toString(), products);

      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        products: products,
        dataSource: DataSource.server,
        lastUpdated: DateTime.now(),
        currentPage: 1,
        hasReachedMax: products.isEmpty,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: "Lỗi tải sản phẩm: ${e.toString()}",
      ));
    }
  }

  Future<void> _getProductByBrandId(
    GetProductsByBrandEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        isRefreshing: false,
        errorMessage: null,
      ));

      final brandIdString = event.brandId.toString();

      final cachedProducts = await _loadCachedProductsForBrand(brandIdString);
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        emit(state.copyWith(
          isLoading: false,
          isRefreshing: true,
          products: cachedProducts,
          dataSource: DataSource.cache,
          currentPage: 1,
          hasReachedMax: false,
          errorMessage: null,
        ));
      }

      final products = await _getProductsByBrandUseCase.call(brandIdString);

      await _cacheProductsForBrand(brandIdString, products);

      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        products: products,
        dataSource: DataSource.server,
        lastUpdated: DateTime.now(),
        currentPage: 1,
        hasReachedMax: products.isEmpty,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: "Lỗi tải sản phẩm theo thương hiệu: ${e.toString()}",
      ));
    }
  }

  Future<void> _loadProductsWithCache(
    LoadProductsWithCache event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        isRefreshing: false,
        errorMessage: null,
      ));

      final cachedProducts =
          await _loadCachedProducts(page: event.page, limit: event.limit);

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        emit(state.copyWith(
          isLoading: false,
          isRefreshing: true,
          products: cachedProducts,
          errorMessage: null,
          dataSource: DataSource.cache,
          lastUpdated: DateTime.now(),
        ));
      }

      final freshProducts = await _getProductsIsActiveUseCase.call(
        page: event.page,
        limit: event.limit,
        forceRefresh: false,
      );

      if (freshProducts.isNotEmpty) {
        await _cacheProducts(freshProducts, event.page, event.limit);

        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          products: freshProducts.toSet().toList(),
          errorMessage: null,
          dataSource: DataSource.server,
          lastUpdated: DateTime.now(),
          currentPage: event.page,
          hasReachedMax: freshProducts.length < event.limit,
        ));
      } else {
        if (cachedProducts != null && cachedProducts.isNotEmpty) {
          emit(state.copyWith(
            isLoading: false,
            isRefreshing: false,
            errorMessage: "Không có dữ liệu mới từ server",
          ));
        } else {
          emit(state.copyWith(
            isLoading: false,
            isRefreshing: false,
            products: [],
            errorMessage: "Không có dữ liệu sản phẩm",
            dataSource: DataSource.none,
          ));
        }
      }
    } catch (error) {
      final cachedProducts =
          await _loadCachedProducts(page: event.page, limit: event.limit);

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          products: cachedProducts,
          errorMessage: "Lỗi kết nối, hiển thị dữ liệu đã lưu",
          dataSource: DataSource.cache,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          errorMessage: error.toString(),
          dataSource: DataSource.none,
        ));
      }
    }
  }

  Future<void> _getProducts(
    GetProductIsActive event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, errorMessage: null));
      final response = await _getProductsIsActiveUseCase.call();

      if (response.isNotEmpty) {
        await _cacheProducts(response, 1, response.length);

        emit(state.copyWith(
          isLoading: false,
          products: response.toSet().toList(),
          errorMessage: null,
          dataSource: DataSource.server,
          lastUpdated: DateTime.now(),
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          products: [],
          errorMessage: "Không có dữ liệu",
        ));
      }
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _loadProductsFromCache(
    LoadProductsFromCache event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true));
      final cachedProducts =
          await _loadCachedProducts(page: event.page, limit: event.limit);

      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        emit(state.copyWith(
          isLoading: false,
          products: cachedProducts,
          dataSource: DataSource.cache,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          errorMessage: "Không có dữ liệu trong cache",
        ));
      }
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<void> _refreshProducts(
    RefreshProducts event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(state.copyWith(isRefreshing: true));
      final response = await _getProductsIsActiveUseCase.call(
        page: event.page,
        limit: event.limit,
        forceRefresh: true,
      );

      if (response.isNotEmpty) {
        await _cacheProducts(response, event.page, event.limit);
        emit(state.copyWith(
          isRefreshing: false,
          products: response.toSet().toList(),
          dataSource: DataSource.server,
          lastUpdated: DateTime.now(),
        ));
      } else {
        emit(state.copyWith(
          isRefreshing: false,
          errorMessage: "Không có dữ liệu từ server",
        ));
      }
    } catch (error) {
      emit(state.copyWith(isRefreshing: false, errorMessage: error.toString()));
    }
  }

  Future<void> _loadMoreProducts(
    LoadMoreProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (state.hasReachedMax) return;

    try {
      emit(state.copyWith(isLoading: true));

      final response = await _getProductsIsActiveUseCase.call(
        page: event.page,
        limit: event.limit,
        forceRefresh: false,
      );

      if (response.isEmpty) {
        emit(state.copyWith(isLoading: false, hasReachedMax: true));
        return;
      }

      await _cacheProducts(response, event.page, event.limit);

      final updatedProducts = {...state.products, ...response}.toList();

      emit(state.copyWith(
        isLoading: false,
        products: updatedProducts,
        currentPage: event.page,
        dataSource: DataSource.server,
        hasReachedMax: response.length < event.limit,
      ));
    } catch (error) {
      emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
    }
  }

  Future<List<ProductModel>?> _loadCachedProducts({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final cacheKey = 'products_page_${page}_limit_$limit';
      if (!_cacheService.isCacheValid(cacheKey)) return null;

      final cachedIds = _metadataBox.get('${cacheKey}_data');
      if (cachedIds == null) return null;

      final ids =
          List<String>.from((cachedIds as List).map((e) => e.toString()));
      final products = ids
          .map((id) => _productsBox.get(id))
          .whereType<ProductModel>()
          .toList();

      return products.isEmpty ? null : products;
    } catch (e) {
      print('❌ Error loading cached products: $e');
      return null;
    }
  }

  Future<List<ProductModel>?> _loadCachedProductsForType(String typeId) async {
    try {
      final cacheKey = 'products_type_$typeId';
      if (!_cacheService.isCacheValid(cacheKey)) return null;

      final cachedIds = _metadataBox.get('${cacheKey}_data');
      if (cachedIds == null) return null;

      final ids =
          List<String>.from((cachedIds as List).map((e) => e.toString()));
      final products = ids
          .map((id) => _productsBox.get(id))
          .whereType<ProductModel>()
          .toList();

      return products.isEmpty ? null : products;
    } catch (e) {
      print('❌ Error loading cached products for type: $e');
      return null;
    }
  }

  Future<List<ProductModel>?> _loadCachedProductsForBrand(
      String brandId) async {
    try {
      final cacheKey = 'products_brand_$brandId';
      if (!_cacheService.isCacheValid(cacheKey)) return null;

      final cachedIds = _metadataBox.get('${cacheKey}_data');
      if (cachedIds == null) return null;

      final ids =
          List<String>.from((cachedIds as List).map((e) => e.toString()));
      final products = ids
          .map((id) => _productsBox.get(id))
          .whereType<ProductModel>()
          .toList();

      return products.isEmpty ? null : products;
    } catch (e) {
      print('❌ Error loading cached products for brand: $e');
      return null;
    }
  }

  Future<void> _cacheProducts(
      List<ProductModel> products, int page, int limit) async {
    final cacheKey = 'products_page_${page}_limit_$limit';
    final ids = products.map((p) => 'product_${p.id}').toList();

    for (final product in products) {
      await _productsBox.put('product_${product.id}', product);
    }

    await _metadataBox.put('${cacheKey}_data', ids);
    await _metadataBox.put(
        '${cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _cacheProductsForType(
      String typeId, List<ProductModel> products) async {
    final cacheKey = 'products_type_$typeId';
    final ids = products.map((p) => 'product_${p.id}').toList();

    for (final product in products) {
      await _productsBox.put('product_${product.id}', product);
    }

    await _metadataBox.put('${cacheKey}_data', ids);
    await _metadataBox.put(
        '${cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _cacheProductsForBrand(
      String brandId, List<ProductModel> products) async {
    final cacheKey = 'products_brand_$brandId';
    final ids = products.map((p) => 'product_${p.id}').toList();

    for (final product in products) {
      await _productsBox.put('product_${product.id}', product);
    }

    await _metadataBox.put('${cacheKey}_data', ids);
    await _metadataBox.put(
        '${cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _clearProductsCache(
      ClearProductsCache event, Emitter<ProductState> emit) async {
    await _cacheService.clearAllCache();
    emit(state.copyWith(products: [], dataSource: DataSource.none));
  }

  @override
  Future<void> close() {
    print('\n🔴 ProductBloc closing...');
    _productChannel?.unsubscribe();
    _discountChannel?.unsubscribe();

    _realtimeDebounce?.cancel();
    _discountDebounce?.cancel();

    print('✅ ProductBloc closed\n');

    return super.close();
  }
}
