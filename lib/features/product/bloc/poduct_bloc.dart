// import 'package:ecommerce_app/features/product/domain/usecase/get_products_is_active.dart';
// import 'package:ecommerce_app/service/cache_service.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ecommerce_app/features/product/bloc/product_event.dart';
// import 'package:ecommerce_app/features/product/bloc/product_state.dart';
// import 'package:ecommerce_app/features/product/data/models/product_model.dart';
// import 'package:hive_flutter/hive_flutter.dart';

// class ProductBloc extends Bloc<ProductEvent, ProductState> {
//   final GetProductsIsActive _getProductsIsActiveUseCase;
//   final CacheService _cacheService = CacheService();

//   Box<ProductModel> get _productsBox =>
//       Hive.box<ProductModel>('products_cache');
//   Box get _metadataBox => Hive.box('cache_metadata');

//   ProductBloc({
//     required GetProductsIsActive getProductsIsActiveUseCase,
//   })  : _getProductsIsActiveUseCase = getProductsIsActiveUseCase,
//         super(const ProductState()) {
//     on<GetProductIsActive>(_getProducts);
//     on<LoadProductsFromCache>(_loadProductsFromCache);
//     on<RefreshProducts>(_refreshProducts);
//     on<LoadProductsWithCache>(_loadProductsWithCache);
//     on<ClearProductsCache>(_clearProductsCache);
//     on<LoadMoreProducts>(_loadMoreProducts);
//   }

//   // -------------------- LOAD WITH CACHE --------------------
//   Future<void> _loadProductsWithCache(
//     LoadProductsWithCache event,
//     Emitter<ProductState> emit,
//   ) async {
//     try {
//       emit(state.copyWith(
//         isLoading: true,
//         isRefreshing: false,
//         errorMessage: null,
//       ));

//       final cachedProducts = await _loadCachedProducts(
//         page: event.page,
//         limit: event.limit,
//       );

//       if (cachedProducts != null && cachedProducts.isNotEmpty) {
//         emit(state.copyWith(
//           isLoading: false,
//           isRefreshing: true,
//           products: cachedProducts,
//           errorMessage: null,
//           dataSource: DataSource.cache,
//           lastUpdated: DateTime.now(),
//         ));
//       }

//       try {
//         final freshProducts = await _getProductsIsActiveUseCase.call();

//         if (freshProducts.isNotEmpty) {
//           await _cacheProducts(freshProducts, event.page, event.limit);

//           emit(state.copyWith(
//             isLoading: false,
//             isRefreshing: false,
//             products: freshProducts.toSet().toList(),
//             errorMessage: null,
//             dataSource: DataSource.server,
//             lastUpdated: DateTime.now(),
//           ));
//         } else if (cachedProducts == null || cachedProducts.isEmpty) {
//           emit(state.copyWith(
//             isLoading: false,
//             isRefreshing: false,
//             products: [],
//             errorMessage: "Không có dữ liệu sản phẩm",
//             dataSource: DataSource.none,
//           ));
//         }
//       } catch (serverError) {
//         if (cachedProducts != null && cachedProducts.isNotEmpty) {
//           emit(state.copyWith(
//             isLoading: false,
//             isRefreshing: false,
//             products: cachedProducts,
//             errorMessage:
//                 "Không thể cập nhật dữ liệu mới, đang hiển thị dữ liệu đã lưu",
//             dataSource: DataSource.cache,
//           ));
//         } else {
//           emit(state.copyWith(
//             isLoading: false,
//             isRefreshing: false,
//             products: [],
//             errorMessage: "Lỗi khi tải dữ liệu: ${serverError.toString()}",
//             dataSource: DataSource.none,
//           ));
//         }
//       }
//     } catch (error) {
//       emit(state.copyWith(
//         isLoading: false,
//         isRefreshing: false,
//         errorMessage: error.toString(),
//         dataSource: DataSource.none,
//       ));
//     }
//   }

//   // -------------------- GET PRODUCTS --------------------
//   Future<void> _getProducts(
//     GetProductIsActive event,
//     Emitter<ProductState> emit,
//   ) async {
//     try {
//       emit(state.copyWith(isLoading: true, errorMessage: null));

//       final response = await _getProductsIsActiveUseCase.call();

//       if (response.isNotEmpty) {
//         await _cacheProducts(response, 1, response.length);

//         emit(state.copyWith(
//           isLoading: false,
//           products: response.toSet().toList(),
//           errorMessage: null,
//           dataSource: DataSource.server,
//           lastUpdated: DateTime.now(),
//         ));
//       } else {
//         emit(state.copyWith(
//           isLoading: false,
//           products: [],
//           errorMessage: "Lỗi khi tải dữ liệu",
//           dataSource: DataSource.none,
//         ));
//       }
//     } catch (error) {
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: error.toString(),
//         dataSource: DataSource.none,
//       ));
//     }
//   }

//   // -------------------- LOAD FROM CACHE --------------------
//   Future<void> _loadProductsFromCache(
//     LoadProductsFromCache event,
//     Emitter<ProductState> emit,
//   ) async {
//     try {
//       emit(state.copyWith(isLoading: true, errorMessage: null));

//       final cachedProducts = await _loadCachedProducts(
//         page: event.page,
//         limit: event.limit,
//       );

//       if (cachedProducts != null && cachedProducts.isNotEmpty) {
//         emit(state.copyWith(
//           isLoading: false,
//           products: cachedProducts,
//           errorMessage: null,
//           dataSource: DataSource.cache,
//           lastUpdated: DateTime.now(),
//         ));
//       } else {
//         emit(state.copyWith(
//           isLoading: false,
//           products: [],
//           errorMessage: "Không có dữ liệu trong cache",
//           dataSource: DataSource.none,
//         ));
//       }
//     } catch (error) {
//       emit(state.copyWith(
//         isLoading: false,
//         errorMessage: error.toString(),
//         dataSource: DataSource.none,
//       ));
//     }
//   }

//   // -------------------- REFRESH --------------------
//   Future<void> _refreshProducts(
//     RefreshProducts event,
//     Emitter<ProductState> emit,
//   ) async {
//     try {
//       emit(state.copyWith(isRefreshing: true, errorMessage: null));

//       final response = await _getProductsIsActiveUseCase.call();

//       if (response.isNotEmpty) {
//         await _cacheProducts(response, event.page, event.limit);

//         emit(state.copyWith(
//           isRefreshing: false,
//           products: response.toSet().toList(),
//           errorMessage: null,
//           dataSource: DataSource.server,
//           lastUpdated: DateTime.now(),
//         ));
//       } else {
//         emit(state.copyWith(
//           isRefreshing: false,
//           errorMessage: "Không có dữ liệu từ server",
//         ));
//       }
//     } catch (error) {
//       emit(state.copyWith(isRefreshing: false, errorMessage: error.toString()));
//     }
//   }

//   // -------------------- LOAD MORE --------------------
//   Future<void> _loadMoreProducts(
//     LoadMoreProducts event,
//     Emitter<ProductState> emit,
//   ) async {
//     if (state.hasReachedMax) return;

//     try {
//       emit(state.copyWith(isLoading: true));

//       final cachedProducts = await _loadCachedProducts(
//         page: event.page,
//         limit: event.limit,
//       );

//       List<ProductModel> newProducts = [];

//       if (cachedProducts != null && cachedProducts.isNotEmpty) {
//         newProducts = cachedProducts;
//       } else {
//         final response = await _getProductsIsActiveUseCase.call();
//         if (response.isNotEmpty) {
//           await _cacheProducts(response, event.page, event.limit);
//           newProducts = response;
//         } else {
//           emit(state.copyWith(isLoading: false, hasReachedMax: true));
//           return;
//         }
//       }

//       final updatedProducts = [
//         ...{...state.products, ...newProducts}
//       ].toList();

//       emit(state.copyWith(
//         isLoading: false,
//         products: updatedProducts,
//         currentPage: event.page,
//         dataSource:
//             cachedProducts != null ? DataSource.cache : DataSource.server,
//         hasReachedMax: newProducts.length < event.limit,
//       ));
//     } catch (error) {
//       emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
//     }
//   }

//   // -------------------- LOAD CACHED PRODUCTS --------------------
//   Future<List<ProductModel>?> _loadCachedProducts({
//     int page = 1,
//     int limit = 20,
//   }) async {
//     try {
//       final cacheKey = 'products_page_${page}_limit_$limit';

//       if (!_cacheService.isCacheValid(cacheKey)) return null;

//       final cachedData = _metadataBox.get('${cacheKey}_data');
//       if (cachedData == null) return null;

//       List<String> productIds = [];

//       if (cachedData is List<String>) {
//         productIds = cachedData;
//       } else if (cachedData is List) {
//         productIds = cachedData.map((e) => e.toString()).toList();
//       } else if (cachedData is String) {
//         productIds = cachedData.split(',').where((s) => s.isNotEmpty).toList();
//       } else {
//         await _metadataBox.delete('${cacheKey}_data');
//         await _metadataBox.delete('${cacheKey}_timestamp');
//         return null;
//       }

//       final products = <ProductModel>[];
//       final seenIds = <String>{};

//       for (final productId in productIds) {
//         if (!seenIds.contains(productId)) {
//           final product = _productsBox.get(productId.trim());
//           if (product != null) {
//             products.add(product);
//             seenIds.add(productId);
//           }
//         }
//       }

//       return products.isEmpty ? null : products;
//     } catch (e) {
//       print('❌ Error loading cached products: $e');
//       return null;
//     }
//   }

//   // -------------------- CACHE PRODUCTS --------------------
//   Future<void> _cacheProducts(
//     List<ProductModel> products,
//     int page,
//     int limit,
//   ) async {
//     try {
//       final cacheKey = 'products_page_${page}_limit_$limit';

//       final productIds =
//           products.map((p) => 'product_${p.id}').toSet().toList();

//       for (final product in products) {
//         await _productsBox.put('product_${product.id}', product);
//       }

//       final existingIdsDynamic =
//           _metadataBox.get('${cacheKey}_data', defaultValue: <dynamic>[]);

//       final existingIds =
//           List<String>.from(existingIdsDynamic.map((e) => e.toString()));

//       final uniqueIds = {...existingIds, ...productIds}.toList();

//       await _metadataBox.put('${cacheKey}_data', uniqueIds);
//       await _metadataBox.put(
//         '${cacheKey}_timestamp',
//         DateTime.now().millisecondsSinceEpoch,
//       );
//     } catch (e) {
//       print('❌ Error caching products: $e');
//     }
//   }

//   // -------------------- CLEAR CACHE --------------------
//   Future<void> _clearProductsCache(
//     ClearProductsCache event,
//     Emitter<ProductState> emit,
//   ) async {
//     try {
//       await clearCache();
//       emit(state.copyWith(
//         products: [],
//         errorMessage: null,
//         dataSource: DataSource.none,
//       ));
//     } catch (error) {
//       emit(state.copyWith(
//         errorMessage: "Lỗi khi xóa cache: ${error.toString()}",
//       ));
//     }
//   }

//   Future<void> clearCache() async {
//     try {
//       await _cacheService.clearAllCache();
//     } catch (e) {
//       print('❌ Error clearing cache: $e');
//     }
//   }

//   CacheStats getCacheStats() {
//     return _cacheService.getCacheStats();
//   }
// }
import 'dart:async';
import 'package:ecommerce_app/features/product/domain/usecase/get_products_is_active.dart';
import 'package:ecommerce_app/service/cache_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/features/product/bloc/product_event.dart';
import 'package:ecommerce_app/features/product/bloc/product_state.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetProductsIsActive _getProductsIsActiveUseCase;
  final CacheService _cacheService = CacheService();
  final SupabaseClient _supabase = Supabase.instance.client;

  Box<ProductModel> get _productsBox =>
      Hive.box<ProductModel>('products_cache');
  Box get _metadataBox => Hive.box('cache_metadata');

  RealtimeChannel? _productChannel;
  Timer? _realtimeDebounce;

  ProductBloc({
    required GetProductsIsActive getProductsIsActiveUseCase,
  })  : _getProductsIsActiveUseCase = getProductsIsActiveUseCase,
        super(const ProductState()) {
    on<GetProductIsActive>(_getProducts);
    on<LoadProductsFromCache>(_loadProductsFromCache);
    on<RefreshProducts>(_refreshProducts);
    on<LoadProductsWithCache>(_loadProductsWithCache);
    on<ClearProductsCache>(_clearProductsCache);
    on<LoadMoreProducts>(_loadMoreProducts);

    _setupRealtimeSubscription();
  }

  // -------------------------
  // Realtime: khi event đến -> bắt buộc fetch server (forceRefresh)
  // -------------------------
  void _setupRealtimeSubscription() {
    // Đảm bảo unsubscribe cũ (nếu có)
    _productChannel?.unsubscribe();

    _productChannel = _supabase
        .channel('public:products')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'products',
          callback: (payload) {
            // payload có thể chứa eventType, newRecord, oldRecord
            print('📡 Realtime event: ${payload.eventType}');
            print('🆕 Record: ${payload.newRecord ?? payload.oldRecord}');

            // debounce: hủy timer cũ và tạo 1 timer mới
            _realtimeDebounce?.cancel();
            _realtimeDebounce = Timer(const Duration(seconds: 2), () {
              // gọi hàm async để fetch và emit
              _handleRealtimeRefresh();
            });
          },
        )
        .subscribe((status, [error]) {
      print('🔔 Subscription status: $status');
      if (error != null) print('⚠️ Realtime subscribe error: $error');
    });
  }

  // Hàm thực hiện refresh bắt buộc (bỏ cache)
  Future<void> _handleRealtimeRefresh() async {
    try {
      print('🔄 Realtime forced refresh: fetching latest products from server');

      // directly call usecase with forceRefresh = true
      final freshProducts = await _getProductsIsActiveUseCase.call(
        page: 1,
        limit: 20,
        forceRefresh: true,
      );

      if (freshProducts.isNotEmpty) {
        // Cập nhật cache (ghi đè)
        await _cacheProducts(freshProducts, 1, 20);

        // Emit state mới từ server
        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          products: freshProducts.toSet().toList(),
          errorMessage: null,
          dataSource: DataSource.server,
          lastUpdated: DateTime.now(),
          currentPage: 1,
          hasReachedMax: freshProducts.length < 20,
        ));

        print(
            '✅ Realtime refresh completed: ${freshProducts.length} products updated');
      } else {
        // Nếu server trả rỗng: tạm thời giữ nguyên state nhưng clear isRefreshing
        emit(state.copyWith(isRefreshing: false));
        print('⚠️ Realtime refresh returned empty list from server');
      }
    } catch (e) {
      print('❌ Error during realtime forced refresh: $e');
      // Không làm crash app, chỉ emit lỗi nhẹ
      emit(state.copyWith(
        isRefreshing: false,
        errorMessage: 'Lỗi khi cập nhật realtime: $e',
      ));
    }
  }

  // -------------------------
  // Các handler Event (giữ nguyên logic của bạn, chỉ thêm best-effort)
  // -------------------------
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
        emit(state.copyWith(
          isLoading: false,
          isRefreshing: false,
          products: [],
          errorMessage: "Không có dữ liệu sản phẩm",
          dataSource: DataSource.none,
        ));
      }
    } catch (error) {
      emit(state.copyWith(
        isLoading: false,
        isRefreshing: false,
        errorMessage: error.toString(),
        dataSource: DataSource.none,
      ));
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
      // Luôn fetch trực tiếp server (bỏ qua cache) khi user trigger refresh
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

  // -------------------------
  // Cache helpers (giữ nguyên logic bạn đã có)
  // -------------------------
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

  Future<void> _clearProductsCache(
      ClearProductsCache event, Emitter<ProductState> emit) async {
    await _cacheService.clearAllCache();
    emit(state.copyWith(products: [], dataSource: DataSource.none));
  }

  @override
  Future<void> close() {
    _productChannel?.unsubscribe();
    _realtimeDebounce?.cancel();
    return super.close();
  }
}
