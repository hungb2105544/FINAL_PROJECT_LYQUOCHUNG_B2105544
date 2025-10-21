import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/product/data/datasources/product_remote_datasource.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final client = SupabaseConfig.client;
  static const String _tableName = 'products';

  // Hive box names
  static const String _productsBoxName = 'products_cache';
  static const String _metadataBoxName = 'cache_metadata';

  // Cache expiry time (30 minutes)
  static const Duration _cacheExpiry = Duration(minutes: 30);

  // Get Hive boxes
  Box<ProductModel> get _productsBox =>
      Hive.box<ProductModel>(_productsBoxName);
  Box get _metadataBox => Hive.box(_metadataBoxName);
  List<Map<String, dynamic>> _simplifyProductVariants(List<dynamic> variants) {
    final Map<String, Map<String, dynamic>> colorMap = {};

    for (final variant in variants) {
      final String? color = variant['color'];
      final int? variantId =
          variant['id'] != null ? int.tryParse(variant['id'].toString()) : null;

      // Chỉ thêm vào nếu có variantId và color hợp lệ
      if (variantId != null && color != null && !colorMap.containsKey(color)) {
        String? imageUrl;
        final images = variant['product_variant_images'];
        if (images is List && images.isNotEmpty) {
          imageUrl = images.first['image_url'];
        }

        colorMap[color] = {
          'id': variantId,
          'color': color,
          'image_url': imageUrl,
        };
      }
    }

    return colorMap.values.toList();
  }

  List<Map<String, dynamic>> _processProductResponse(
      List<Map<String, dynamic>> response) {
    return response.map((product) {
      final processedProduct = Map<String, dynamic>.from(product);

      if (processedProduct['product_variants'] != null) {
        final simplifiedVariants =
            _simplifyProductVariants(processedProduct['product_variants']);
        processedProduct['product_variants'] = simplifiedVariants;

        print('🎨 Simplified variants for ${product['name']}:');
        for (final variant in simplifiedVariants) {
          print(
              '   - ID: ${variant['id']}, Color: ${variant['color']}, Image: ${variant['image_url']}');
        }
      }

      return processedProduct;
    }).toList();
  }

  // Lấy sản phẩm với cache
  @override
  Future<List<ProductModel>> getProductsIsActive({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    try {
      final String cacheKey = 'products_page_${page}_limit_$limit';

      // Check cache first (if not force refresh)
      if (!forceRefresh) {
        final cachedProducts = await _getCachedProducts(cacheKey);
        if (cachedProducts != null) {
          print('📱 Retrieved ${cachedProducts.length} products from cache');
          return cachedProducts;
        }
      }

      final int offset = (page - 1) * limit;
      print(
          '🔍 Fetching products from server: page=$page, limit=$limit, offset=$offset');

      final response = await client
          .from(_tableName)
          .select('''
                  *,
                  brands (id, brand_name, image_url, description),
                  product_types (id, type_name, description),
                  product_variants (
                    id, color, sku, additional_price, is_active,
                    sizes (id, size_name),
                    product_variant_images (id, image_url, sort_order)
                  ),
                  
                  product_ratings (
                    id, rating, title, comment, images, pros, cons, user_id, created_at
                  ),
                  product_sizes(
                    id,
                    sizes(id,size_name)
                  ),
                  inventory (
                    id, branch_id, quantity, reserved_quantity,
                    branches (id, name, phone)
                  ),
                  product_price_history(id, product_id, price, effective_date,end_date,is_active, created_by, created_at)
                ''')
          .eq('is_active', true)
          .order('created_at', ascending: false)
          .range(offset, offset + limit - 1);

      print('📦 Supabase Response: ${response.length} products fetched');
      // print(const JsonEncoder.withIndent('  ').convert(response));
      print(response.toString());
      final processedResponse =
          _processProductResponse(response.cast<Map<String, dynamic>>());

      // Lấy khuyến mãi đang hoạt động cho từng sản phẩm
      final productsWithDiscounts =
          await Future.wait(processedResponse.map((json) async {
        final discountJson = await client.rpc(
          'get_active_discount_for_product',
          params: {'p_product_id': json['id']},
        );
        if (discountJson != null) {
          json['product_discounts'] = [discountJson];
        }
        return json;
      }));

      final List<ProductModel> products = productsWithDiscounts
          .map((json) => ProductModel.fromJson(json))
          .toList();

      // Cache the results
      await _cacheProducts(cacheKey, products);

      return products;
    } on PostgrestException catch (e) {
      print('❌ Supabase PostgrestException: ${e.message}');
      // Try to return cached data if network fails
      final cachedProducts =
          await _getCachedProducts('products_page_${page}_limit_$limit');
      if (cachedProducts != null) {
        print('📱 Returning cached data due to network error');
        return cachedProducts;
      }
      throw _handleSupabaseError(e);
    } on Exception catch (e) {
      print('❌ General Exception: $e');
      // Try to return cached data if error occurs
      final cachedProducts =
          await _getCachedProducts('products_page_${page}_limit_$limit');
      if (cachedProducts != null) {
        print('📱 Returning cached data due to error');
        return cachedProducts;
      }
      throw Exception('Failed to fetch products: $e');
    }
  }

  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      print('🔍 Fetching product by ID: $id');

      // Check cache first
      final cachedProduct = _productsBox.get('product_$id');
      if (cachedProduct != null && _isCacheValid('product_$id')) {
        print('📱 Retrieved product from cache: ${cachedProduct.name}');
        return cachedProduct;
      }

      final int productId = int.tryParse(id) ?? 0;
      if (productId <= 0) {
        throw ArgumentError('Invalid product ID: $id');
      }

      final response = await client
          .from(_tableName)
          .select('*')
          .eq('id', productId)
          .eq('is_active', true)
          .single();

      print('📦 Product fetched: ${response['name']}');

      final processedResponse =
          _processProductResponse([Map<String, dynamic>.from(response)]);
      final product = ProductModel.fromJson(processedResponse.first);

      // Cache the product
      await _productsBox.put('product_$id', product);
      _metadataBox.put(
          'product_${id}_timestamp', DateTime.now().millisecondsSinceEpoch);

      return product;
    } on PostgrestException catch (e) {
      print('❌ Supabase PostgrestException: ${e.message}');
      // Try cached data if available
      final cachedProduct = _productsBox.get('product_$id');
      if (cachedProduct != null) {
        print('📱 Returning cached product due to network error');
        return cachedProduct;
      }

      if (e.code == 'PGRST116') {
        throw ProductNotFoundException('Product with ID $id not found');
      }
      throw _handleSupabaseError(e);
    } on Exception catch (e) {
      print('❌ General Exception: $e');
      // Try cached data if available
      final cachedProduct = _productsBox.get('product_$id');
      if (cachedProduct != null) {
        print('📱 Returning cached product due to error');
        return cachedProduct;
      }
      throw Exception('Failed to fetch product by ID $id: $e');
    }
  }

  @override
  Future<List<ProductModel>> getProductsByBrand(int brandId) async {
    try {
      final response = await client
          .from(_tableName)
          .select(('''
                  *,
                  brands (id, brand_name, image_url, description),
                  product_types (id, type_name, description),
                  product_variants (
                    id, color, sku, additional_price, is_active,
                    sizes (id, size_name),
                    product_variant_images (id, image_url, sort_order)
                  ),
                  
                  product_ratings (
                    id, rating, title, comment, images, pros, cons, user_id, created_at
                  ),
                  product_sizes(
                    id,
                    sizes(id,size_name)
                  ),
                  inventory (
                    id, branch_id, quantity, reserved_quantity,
                    branches (id, name, phone)
                  ),
                  product_price_history(id, product_id, price, effective_date,end_date,is_active, created_by, created_at)
                '''))
          .eq('brand_id', brandId)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      print('📦 Products by type fetched: ${response.length} products');

      final processedResponse =
          _processProductResponse(response.cast<Map<String, dynamic>>());
      final productsWithDiscounts =
          await Future.wait(processedResponse.map((json) async {
        final discountJson = await client.rpc(
          'get_active_discount_for_product',
          params: {'p_product_id': json['id']},
        );
        if (discountJson != null) {
          json['product_discounts'] = [discountJson];
        }
        return json;
      }));

      final List<ProductModel> products = productsWithDiscounts
          .map((json) => ProductModel.fromJson(json))
          .toList();
      return products;
    } on PostgrestException catch (e) {
      print('❌ Supabase PostgrestException: ${e.message}');
      throw _handleSupabaseError(e);
    } on Exception catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Failed to fetch products by type $brandId: $e');
    }
  }

  // Tìm kiếm sản phẩm theo loại sản phẩm với cache
  @override
  Future<List<ProductModel>> getProductsByType(String typeId) async {
    try {
      final int? typeIdInt = int.tryParse(typeId);
      if (typeIdInt == null) {
        throw ArgumentError('Invalid type ID: $typeId');
      }

      final response = await client
          .from(_tableName)
          .select(('''
                  *,
                  brands (id, brand_name, image_url, description),
                  product_types (id, type_name, description),
                  product_variants (
                    id, color, sku, additional_price, is_active,
                    sizes (id, size_name),
                    product_variant_images (id, image_url, sort_order)
                  ),
                  
                  product_ratings (
                    id, rating, title, comment, images, pros, cons, user_id, created_at
                  ),
                  product_sizes(
                    id,
                    sizes(id,size_name)
                  ),
                  inventory (
                    id, branch_id, quantity, reserved_quantity,
                    branches (id, name, phone)
                  ),
                  product_price_history(id, product_id, price, effective_date,end_date,is_active, created_by, created_at)
                '''))
          .eq('type_id', typeIdInt)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      print('📦 Products by type fetched: ${response.length} products');

      final processedResponse =
          _processProductResponse(response.cast<Map<String, dynamic>>());
      final productsWithDiscounts =
          await Future.wait(processedResponse.map((json) async {
        final discountJson = await client.rpc(
          'get_active_discount_for_product',
          params: {'p_product_id': json['id']},
        );
        if (discountJson != null) {
          json['product_discounts'] = [discountJson];
        }
        return json;
      }));

      final List<ProductModel> products = productsWithDiscounts
          .map((json) => ProductModel.fromJson(json))
          .toList();
      return products;
    } on PostgrestException catch (e) {
      print('❌ Supabase PostgrestException: ${e.message}');
      throw _handleSupabaseError(e);
    } on Exception catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Failed to fetch products by type $typeId: $e');
    }
  }

  // TÌm kiếm sản phẩm
  @override
  Future<List<ProductModel>> searchProducts(String query) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      print('🔍 Searching products with query: "$query"');

      // For search, we typically don't cache as results can be very dynamic
      final response = await client
          .from(_tableName)
          .select('*')
          .eq('is_active', true)
          .or('name.ilike.%$query%,'
              'description.ilike.%$query%,'
              'sku.ilike.%$query%,'
              'material.ilike.%$query%,'
              'color.ilike.%$query%')
          .order('average_rating', ascending: false)
          .order('created_at', ascending: false);

      print('📦 Search results: ${response.length} products found');

      final processedResponse =
          _processProductResponse(response.cast<Map<String, dynamic>>());

      final List<ProductModel> products =
          processedResponse.map((json) => ProductModel.fromJson(json)).toList();

      return products;
    } on PostgrestException catch (e) {
      print('❌ Supabase PostgrestException: ${e.message}');
      throw _handleSupabaseError(e);
    } on Exception catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Failed to search products with query "$query": $e');
    }
  }

  /// Get featured products với cache
  @override
  Future<List<ProductModel>> getFeaturedProducts({
    int limit = 10,
    bool forceRefresh = false,
  }) async {
    try {
      print('🔍 Fetching featured products');

      const String cacheKey = 'featured_products';

      // Check cache first
      if (!forceRefresh) {
        final cachedProducts = await _getCachedProducts(cacheKey);
        if (cachedProducts != null) {
          print(
              '📱 Retrieved ${cachedProducts.length} featured products from cache');
          return cachedProducts.take(limit).toList();
        }
      }

      final response = await client
          .from(_tableName)
          .select('*')
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('average_rating', ascending: false)
          .limit(limit);

      print('📦 Featured products fetched: ${response.length} products');

      final processedResponse =
          _processProductResponse(response.cast<Map<String, dynamic>>());

      final products =
          processedResponse.map((json) => ProductModel.fromJson(json)).toList();

      // Cache the results
      await _cacheProducts(cacheKey, products);

      return products;
    } catch (e) {
      print('❌ Error fetching featured products: $e');
      // Try cached data
      final cachedProducts = await _getCachedProducts('featured_products');
      if (cachedProducts != null) {
        print('📱 Returning cached featured products due to error');
        return cachedProducts.take(limit).toList();
      }
      throw Exception('Failed to fetch featured products: $e');
    }
  }

  // Cache helper methods
  Future<List<ProductModel>?> _getCachedProducts(String cacheKey) async {
    try {
      if (!_isCacheValid(cacheKey)) {
        return null;
      }

      final cachedData = _metadataBox.get('${cacheKey}_data');
      if (cachedData == null) return null;

      // Safely cast to List<String>
      List<String> productIds;
      if (cachedData is List<String>) {
        productIds = cachedData;
      } else if (cachedData is List) {
        // Cast List<dynamic> to List<String>
        productIds = cachedData.cast<String>();
      } else {
        print('❌ Invalid cached data type: ${cachedData.runtimeType}');
        return null;
      }

      final products = <ProductModel>[];
      for (final productId in productIds) {
        final product = _productsBox.get(productId);
        if (product != null) {
          products.add(product);
        }
      }

      return products.isEmpty ? null : products;
    } catch (e) {
      print('❌ Error getting cached products: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> fetchNearestStock(
      String userId, int productId, id,
      {int? variantId}) async {
    final response =
        await client.rpc('get_nearest_branch_stock_by_user', params: {
      'user_id': userId,
      'product_id': productId,
      'variant_id': variantId,
    });

    if (response.data != null && response.data.isNotEmpty) {
      return response.data[0]; // branch gần nhất
    }
    return null;
  }

  Future<void> _cacheProducts(
      String cacheKey, List<ProductModel> products) async {
    try {
      final productIds = <String>[];

      for (final product in products) {
        final productKey = 'product_${product.id}';
        await _productsBox.put(productKey, product);
        productIds.add(productKey);
      }

      // Store the list of product IDs for this cache key
      await _metadataBox.put('${cacheKey}_data', productIds);
      await _metadataBox.put(
          '${cacheKey}_timestamp', DateTime.now().millisecondsSinceEpoch);

      print('💾 Cached ${products.length} products with key: $cacheKey');
    } catch (e) {
      print('❌ Error caching products: $e');
    }
  }

  bool _isCacheValid(String cacheKey) {
    try {
      final timestamp = _metadataBox.get('${cacheKey}_timestamp') as int?;
      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime);

      return difference < _cacheExpiry;
    } catch (e) {
      print('❌ Error checking cache validity: $e');
      return false;
    }
  }

  // Cache management methods
  Future<void> clearCache() async {
    try {
      await _productsBox.clear();
      await _metadataBox.clear();
      print('🧹 Cache cleared successfully');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  Future<void> clearExpiredCache() async {
    try {
      final keys = _metadataBox.keys.toList();
      final now = DateTime.now().millisecondsSinceEpoch;

      for (final key in keys) {
        if (key.toString().endsWith('_timestamp')) {
          final timestamp = _metadataBox.get(key) as int?;
          if (timestamp != null) {
            final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
            final difference =
                DateTime.fromMillisecondsSinceEpoch(now).difference(cacheTime);

            if (difference > _cacheExpiry) {
              final cacheKey = key.toString().replaceAll('_timestamp', '');
              await _metadataBox.delete(key);
              await _metadataBox.delete('${cacheKey}_data');
              print('🧹 Expired cache cleared: $cacheKey');
            }
          }
        }
      }
    } catch (e) {
      print('❌ Error clearing expired cache: $e');
    }
  }

  /// Increment view count for a product
  Future<void> incrementViewCount(String productId) async {
    try {
      final int id = int.tryParse(productId) ?? 0;
      if (id <= 0) return;

      await client.rpc('increment_view_count', params: {'product_id': id});
      print('👁️ View count incremented for product $productId');
    } catch (e) {
      print('❌ Error incrementing view count: $e');
      // Don't throw error as this is not critical
    }
  }

  /// Update product rating (if you handle ratings in products table)
  Future<void> updateProductRating(
      String productId, double newRating, int newTotalRatings) async {
    try {
      final int id = int.tryParse(productId) ?? 0;
      if (id <= 0) return;

      await client.from(_tableName).update({
        'average_rating': newRating,
        'total_ratings': newTotalRatings,
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', id);

      // Update cached product if exists
      final cachedProduct = _productsBox.get('product_$productId');
      if (cachedProduct != null) {
        final updatedProduct = cachedProduct.copyWith(
          averageRating: newRating,
          totalRatings: newTotalRatings,
        );
        await _productsBox.put('product_$productId', updatedProduct);
      }

      print('⭐ Rating updated for product $productId');
    } catch (e) {
      print('❌ Error updating product rating: $e');
      throw Exception('Failed to update product rating: $e');
    }
  }

  Exception _handleSupabaseError(PostgrestException e) {
    switch (e.code) {
      case 'PGRST116':
        return ProductNotFoundException('Product not found');
      case 'PGRST301':
        return Exception('Database connection error');
      case '42P01':
        return Exception('Table does not exist');
      case '42703':
        return Exception('Column does not exist');
      default:
        return Exception('Database error: ${e.message}');
    }
  }
}

class ProductNotFoundException implements Exception {
  final String message;

  const ProductNotFoundException(this.message);

  @override
  String toString() => 'ProductNotFoundException: $message';
}

class DatabaseException implements Exception {
  final String message;
  final String? code;

  const DatabaseException(this.message, [this.code]);

  @override
  String toString() =>
      'DatabaseException: $message${code != null ? ' (Code: $code)' : ''}';
}
