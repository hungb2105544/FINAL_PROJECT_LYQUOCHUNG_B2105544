// import 'dart:async';
// import 'package:ecommerce_app/features/product/domain/usecase/get_product_by_type.dart';
// import 'package:ecommerce_app/features/product/domain/usecase/get_products_is_active.dart';

// import 'package:ecommerce_app/service/cache_service.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ecommerce_app/features/product/bloc/product_event.dart';
// import 'package:ecommerce_app/features/product/bloc/product_state.dart';
// import 'package:ecommerce_app/features/product/data/models/product_model.dart';
// import 'package:hive_flutter/hive_flutter.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// class ProductBloc extends Bloc<ProductEvent, ProductState> {
//   final GetProductsIsActive _getProductsIsActiveUseCase;
//   final GetProductByType _getProductsByTypeUseCase;
//   final CacheService _cacheService = CacheService();
//   final SupabaseClient _supabase = Supabase.instance.client;

//   Box<ProductModel> get _productsBox =>
//       Hive.box<ProductModel>('products_cache');
//   Box get _metadataBox => Hive.box('cache_metadata');

//   RealtimeChannel? _productChannel;
//   Timer? _realtimeDebounce;

//   ProductBloc({
//     required GetProductsIsActive getProductsIsActiveUseCase,
//     required GetProductByType getProductsByTypeUseCase,
//   })  : _getProductsIsActiveUseCase = getProductsIsActiveUseCase,
//         _getProductsByTypeUseCase = getProductsByTypeUseCase,
//         super(const ProductState()) {
//     on<GetProductIsActive>(_getProducts);
//     on<LoadProductsFromCache>(_loadProductsFromCache);
//     on<RefreshProducts>(_refreshProducts);
//     on<LoadProductsWithCache>(_loadProductsWithCache);
//     on<ClearProductsCache>(_clearProductsCache);
//     on<LoadMoreProducts>(_loadMoreProducts);
//     on<GetProductsByTypeEvent>(_getProductByTypeId);
//     _setupRealtimeSubscription();
//   }

//   // -------------------------
//   // Realtime: khi event đến -> bắt buộc fetch server (forceRefresh)
//   // -------------------------
//   void _setupRealtimeSubscription() {
//     // Đảm bảo unsubscribe cũ (nếu có)
//     _productChannel?.unsubscribe();

//     _productChannel = _supabase
//         .channel('public:products')
//         .onPostgresChanges(
//           event: PostgresChangeEvent.all,
//           schema: 'public',
//           table: 'products',
//           callback: (payload) {
//             // payload có thể chứa eventType, newRecord, oldRecord
//             print('📡 Realtime event: ${payload.eventType}');
//             print('🆕 Record: ${payload.newRecord ?? payload.oldRecord}');

//             // debounce: hủy timer cũ và tạo 1 timer mới
//             _realtimeDebounce?.cancel();
//             _realtimeDebounce = Timer(const Duration(seconds: 2), () {
//               // gọi hàm async để fetch và emit
//               _handleRealtimeRefresh();
//             });
//           },
//         )
//         .subscribe((status, [error]) {
//       print('🔔 Subscription status: $status');
//       if (error != null) print('⚠️ Realtime subscribe error: $error');
//     });
//   }

//   // Hàm thực hiện refresh bắt buộc (bỏ cache)
//   Future<void> _handleRealtimeRefresh() async {
//     try {
//       print('🔄 Realtime forced refresh: fetching latest products from server');

//       // directly call usecase with forceRefresh = true
//       final freshProducts = await _getProductsIsActiveUseCase.call(
//         page: 1,
//         limit: 20,
//         forceRefresh: true,
//       );

//       if (freshProducts.isNotEmpty) {
//         // Cập nhật cache (ghi đè)
//         await _cacheProducts(freshProducts, 1, 20);

//         // Emit state mới từ server
//         emit(state.copyWith(
//           isLoading: false,
//           isRefreshing: false,
//           products: freshProducts.toSet().toList(),
//           errorMessage: null,
//           dataSource: DataSource.server,
//           lastUpdated: DateTime.now(),
//           currentPage: 1,
//           hasReachedMax: freshProducts.length < 20,
//         ));

//         print(
//             '✅ Realtime refresh completed: ${freshProducts.length} products updated');
//       } else {
//         // Nếu server trả rỗng: tạm thời giữ nguyên state nhưng clear isRefreshing
//         emit(state.copyWith(isRefreshing: false));
//         print('⚠️ Realtime refresh returned empty list from server');
//       }
//     } catch (e) {
//       print('❌ Error during realtime forced refresh: $e');
//       // Không làm crash app, chỉ emit lỗi nhẹ
//       emit(state.copyWith(
//         isRefreshing: false,
//         errorMessage: 'Lỗi khi cập nhật realtime: $e',
//       ));
//     }
//   }

//   Future<void> _getProductByTypeId(
//     GetProductsByTypeEvent event,
//     Emitter<ProductState> emit,
//   ) async {
//     try {
//       // ❌ KHÔNG xóa products: [] ở đây nữa.
//       emit(state.copyWith(
//         isLoading: true,
//         isRefreshing: false,
//         errorMessage: null,
//         products: [],
//       ));

//       // Lấy sản phẩm từ cache trước
//       final cachedProducts =
//           await _loadCachedProductsForType(event.typeId.toString());
//       if (cachedProducts != null && cachedProducts.isNotEmpty) {
//         emit(state.copyWith(
//           isLoading: false,
//           products: cachedProducts,
//           dataSource: DataSource.cache,
//         ));
//       }

//       // Sau đó fetch từ server
//       final products =
//           await _getProductsByTypeUseCase.call(event.typeId.toString());

//       emit(state.copyWith(
//         isLoading: false,
//         products: products,
//         dataSource: DataSource.server,
//         lastUpdated: DateTime.now(),
//       ));
//     } catch (e) {
//       emit(state.copyWith(
//           isLoading: false, errorMessage: "Lỗi tải sản phẩm: ${e.toString()}"));
//     }
//   }

//   // -------------------------
//   // Các handler Event (giữ nguyên logic của bạn, chỉ thêm best-effort)
//   // -------------------------
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

//       final cachedProducts =
//           await _loadCachedProducts(page: event.page, limit: event.limit);

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

//       final freshProducts = await _getProductsIsActiveUseCase.call(
//         page: event.page,
//         limit: event.limit,
//         forceRefresh: false,
//       );

//       if (freshProducts.isNotEmpty) {
//         await _cacheProducts(freshProducts, event.page, event.limit);

//         emit(state.copyWith(
//           isLoading: false,
//           isRefreshing: false,
//           products: freshProducts.toSet().toList(),
//           errorMessage: null,
//           dataSource: DataSource.server,
//           lastUpdated: DateTime.now(),
//           currentPage: event.page,
//           hasReachedMax: freshProducts.length < event.limit,
//         ));
//       } else {
//         emit(state.copyWith(
//           isLoading: false,
//           isRefreshing: false,
//           products: [],
//           errorMessage: "Không có dữ liệu sản phẩm",
//           dataSource: DataSource.none,
//         ));
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
//           errorMessage: "Không có dữ liệu",
//         ));
//       }
//     } catch (error) {
//       emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
//     }
//   }

//   Future<void> _loadProductsFromCache(
//     LoadProductsFromCache event,
//     Emitter<ProductState> emit,
//   ) async {
//     try {
//       emit(state.copyWith(isLoading: true));
//       final cachedProducts =
//           await _loadCachedProducts(page: event.page, limit: event.limit);

//       if (cachedProducts != null && cachedProducts.isNotEmpty) {
//         emit(state.copyWith(
//           isLoading: false,
//           products: cachedProducts,
//           dataSource: DataSource.cache,
//         ));
//       } else {
//         emit(state.copyWith(
//           isLoading: false,
//           errorMessage: "Không có dữ liệu trong cache",
//         ));
//       }
//     } catch (error) {
//       emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
//     }
//   }

//   Future<void> _refreshProducts(
//     RefreshProducts event,
//     Emitter<ProductState> emit,
//   ) async {
//     try {
//       emit(state.copyWith(isRefreshing: true));
//       // Luôn fetch trực tiếp server (bỏ qua cache) khi user trigger refresh
//       final response = await _getProductsIsActiveUseCase.call(
//         page: event.page,
//         limit: event.limit,
//         forceRefresh: true,
//       );

//       if (response.isNotEmpty) {
//         await _cacheProducts(response, event.page, event.limit);
//         emit(state.copyWith(
//           isRefreshing: false,
//           products: response.toSet().toList(),
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

//   Future<void> _loadMoreProducts(
//     LoadMoreProducts event,
//     Emitter<ProductState> emit,
//   ) async {
//     if (state.hasReachedMax) return;

//     try {
//       emit(state.copyWith(isLoading: true));

//       final response = await _getProductsIsActiveUseCase.call(
//         page: event.page,
//         limit: event.limit,
//         forceRefresh: false,
//       );

//       if (response.isEmpty) {
//         emit(state.copyWith(isLoading: false, hasReachedMax: true));
//         return;
//       }

//       await _cacheProducts(response, event.page, event.limit);

//       final updatedProducts = {...state.products, ...response}.toList();

//       emit(state.copyWith(
//         isLoading: false,
//         products: updatedProducts,
//         currentPage: event.page,
//         dataSource: DataSource.server,
//         hasReachedMax: response.length < event.limit,
//       ));
//     } catch (error) {
//       emit(state.copyWith(isLoading: false, errorMessage: error.toString()));
//     }
//   }

//   // -------------------------
//   // Cache helpers (giữ nguyên logic bạn đã có)
//   // -------------------------
//   Future<List<ProductModel>?> _loadCachedProducts({
//     int page = 1,
//     int limit = 20,
//   }) async {
//     try {
//       final cacheKey = 'products_page_${page}_limit_$limit';
//       if (!_cacheService.isCacheValid(cacheKey)) return null;

//       final cachedIds = _metadataBox.get('${cacheKey}_data');
//       if (cachedIds == null) return null;

//       final ids =
//           List<String>.from((cachedIds as List).map((e) => e.toString()));
//       final products = ids
//           .map((id) => _productsBox.get(id))
//           .whereType<ProductModel>()
//           .toList();

//       return products.isEmpty ? null : products;
//     } catch (e) {
//       print('❌ Error loading cached products: $e');
//       return null;
//     }
//   }

//   Future<List<ProductModel>?> _loadCachedProductsForType(String typeId) async {
//     try {
//       final cacheKey = 'products_type_$typeId';
//       if (!_cacheService.isCacheValid(cacheKey)) return null;

//       final cachedIds = _metadataBox.get('${cacheKey}_data');
//       if (cachedIds == null) return null;

//       final ids =
//           List<String>.from((cachedIds as List).map((e) => e.toString()));
//       final products = ids
//           .map((id) => _productsBox.get(id))
//           .whereType<ProductModel>()
//           .toList();

//       return products.isEmpty ? null : products;
//     } catch (e) {
//       print('❌ Error loading cached products for type: $e');
//       return null;
//     }
//   }

//   Future<void> _cacheProducts(
//       List<ProductModel> products, int page, int limit) async {
//     final cacheKey = 'products_page_${page}_limit_$limit';
//     final ids = products.map((p) => 'product_${p.id}').toList();

//     for (final product in products) {
//       await _productsBox.put('product_${product.id}', product);
//     }

//     await _metadataBox.put('${cacheKey}_data', ids);
//     await _metadataBox.put(
//         '${cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);
//   }

//   Future<void> _clearProductsCache(
//       ClearProductsCache event, Emitter<ProductState> emit) async {
//     await _cacheService.clearAllCache();
//     emit(state.copyWith(products: [], dataSource: DataSource.none));
//   }

//   @override
//   Future<void> close() {
//     _productChannel?.unsubscribe();
//     _realtimeDebounce?.cancel();
//     return super.close();
//   }
// }
import 'dart:async';
import 'package:ecommerce_app/features/product/domain/usecase/get_product_by_type.dart';
import 'package:ecommerce_app/features/product/domain/usecase/get_products_is_active.dart';
import 'package:ecommerce_app/features/product/domain/usecase/get_product_by_brand.dart'; // Import UseCase mới

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
  final GetProductByBrand _getProductsByBrandUseCase; // Biến UseCase mới
  final CacheService _cacheService = CacheService();
  final SupabaseClient _supabase = Supabase.instance.client;

  Box<ProductModel> get _productsBox =>
      Hive.box<ProductModel>('products_cache');
  Box get _metadataBox => Hive.box('cache_metadata');

  RealtimeChannel? _productChannel;
  Timer? _realtimeDebounce;

  ProductBloc({
    required GetProductsIsActive getProductsIsActiveUseCase,
    required GetProductByType getProductsByTypeUseCase,
    required GetProductByBrand
        getProductsByBrandUseCase, // Tham số constructor mới
  })  : _getProductsIsActiveUseCase = getProductsIsActiveUseCase,
        _getProductsByTypeUseCase = getProductsByTypeUseCase,
        _getProductsByBrandUseCase = getProductsByBrandUseCase, // Gán giá trị
        super(const ProductState()) {
    on<GetProductIsActive>(_getProducts);
    on<LoadProductsFromCache>(_loadProductsFromCache);
    on<RefreshProducts>(_refreshProducts);
    on<LoadProductsWithCache>(_loadProductsWithCache);
    on<ClearProductsCache>(_clearProductsCache);
    on<LoadMoreProducts>(_loadMoreProducts);
    on<GetProductsByTypeEvent>(_getProductByTypeId);
    on<GetProductsByBrandEvent>(_getProductByBrandId); // Đăng ký handler mới
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

  Future<void> _getProductByTypeId(
    GetProductsByTypeEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      // ❌ KHÔNG xóa products: [] ở đây nữa.
      emit(state.copyWith(
        isLoading: true,
        isRefreshing: false,
        errorMessage: null,
        products: [],
      ));

      // Lấy sản phẩm từ cache trước
      final cachedProducts =
          await _loadCachedProductsForType(event.typeId.toString());
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        emit(state.copyWith(
          isLoading: false,
          products: cachedProducts,
          dataSource: DataSource.cache,
        ));
      }

      // Sau đó fetch từ server
      final products =
          await _getProductsByTypeUseCase.call(event.typeId.toString());

      emit(state.copyWith(
        isLoading: false,
        products: products,
        dataSource: DataSource.server,
        lastUpdated: DateTime.now(),
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false, errorMessage: "Lỗi tải sản phẩm: ${e.toString()}"));
    }
  }

  // -------------------- GET PRODUCTS BY BRAND ID --------------------
  Future<void> _getProductByBrandId(
    GetProductsByBrandEvent event,
    Emitter<ProductState> emit,
  ) async {
    try {
      emit(state.copyWith(
        isLoading: true,
        isRefreshing: false,
        errorMessage: null,
        products: [], // Xóa danh sách sản phẩm cũ khi chuyển loại
      ));

      final brandIdString = event.brandId.toString();

      // Lấy sản phẩm từ cache trước
      final cachedProducts = await _loadCachedProductsForBrand(brandIdString);
      if (cachedProducts != null && cachedProducts.isNotEmpty) {
        emit(state.copyWith(
          isLoading: false,
          products: cachedProducts,
          dataSource: DataSource.cache,
          errorMessage: null,
        ));
      }

      // Sau đó fetch từ server
      final products = await _getProductsByBrandUseCase.call(brandIdString);

      // Cache kết quả từ server
      await _cacheProductsForBrand(brandIdString, products);

      emit(state.copyWith(
        isLoading: false,
        products: products,
        dataSource: DataSource.server,
        lastUpdated: DateTime.now(),
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
          isLoading: false,
          errorMessage: "Lỗi tải sản phẩm theo thương hiệu: ${e.toString()}"));
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
  // Cache helpers
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

  // Helper mới cho Brand ID
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

  // Helper mới để cache sản phẩm theo Brand ID
  Future<void> _cacheProductsForBrand(
      String brandId, List<ProductModel> products) async {
    final cacheKey = 'products_brand_$brandId';
    final ids = products.map((p) => 'product_${p.id}').toList();

    for (final product in products) {
      // Đảm bảo ProductModel được cache trong box chung
      await _productsBox.put('product_${product.id}', product);
    }

    // Lưu danh sách IDs vào metadata box
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
