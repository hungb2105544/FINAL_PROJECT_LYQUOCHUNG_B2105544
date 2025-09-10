import 'dart:convert';

import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/product/data/datasources/product_remote_datasource.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final client = SupabaseConfig.client;
  static const String _tableName = 'products';

  // Lấy sản phẩm vớ
  @override
  Future<List<ProductModel>> getProductsIsActive({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final int offset = (page - 1) * limit;

      print('🔍 Fetching products: page=$page, limit=$limit, offset=$offset');

      final response = await client
          .from(_tableName)
          .select('''
                  *,
                  brands (id, brand_name, image_url, description),
                  product_types (id, type_name, description),
                  product_variants (
                    id, color, sku, additional_price, is_active,
                    product_sizes (id, size_name),
                    product_variant_images (id, image_url, sort_order)
                  ),
                  product_discounts (
                    id, discount_percentage, discount_amount, start_date, end_date, is_active
                  ),
                  product_ratings (
                    id, rating, title, comment, images, pros, cons, user_id, created_at
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
      print(const JsonEncoder.withIndent('  ').convert(response));
      final List<ProductModel> products = response
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return products;
    } on PostgrestException catch (e) {
      print('❌ Supabase PostgrestException: ${e.message}');
      print('💥 Error details: ${e.details}');
      print('🐛 Error hint: ${e.hint}');
      throw _handleSupabaseError(e);
    } on Exception catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Failed to fetch products: $e');
    }
  }

  // Tìm kiếm sản phẩm theo ID
  @override
  Future<ProductModel> getProductById(String id) async {
    try {
      print('🔍 Fetching product by ID: $id');

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

      return ProductModel.fromJson(response as Map<String, dynamic>);
    } on PostgrestException catch (e) {
      print('❌ Supabase PostgrestException: ${e.message}');
      if (e.code == 'PGRST116') {
        throw ProductNotFoundException('Product with ID $id not found');
      }
      throw _handleSupabaseError(e);
    } on Exception catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Failed to fetch product by ID $id: $e');
    }
  }

  // Tìm kiếm sản phẩm theo loại sản phẩm
  @override
  Future<List<ProductModel>> getProductsByType(String typeId) async {
    try {
      print('🔍 Fetching products by type: $typeId');

      final int? typeIdInt = int.tryParse(typeId);
      if (typeIdInt == null) {
        throw ArgumentError('Invalid type ID: $typeId');
      }

      final response = await client
          .from(_tableName)
          .select('*')
          .eq('type_id', typeIdInt)
          .eq('is_active', true)
          .order('created_at', ascending: false);

      print('📦 Products by type fetched: ${response.length} products');

      final List<ProductModel> products = response
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
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

      final response = await client
          .from(_tableName)
          .select('*')
          .eq('is_active', true)
          .or('name.ilike.%$query%,'
              'description.ilike.%$query%,'
              'sku.ilike.%$query%,'
              'material.ilike.%$query%,'
              'color.ilike.%$query%')
          .order('average_rating', ascending: false) // Order by rating first
          .order('created_at', ascending: false); // Then by creation date

      print('📦 Search results: ${response.length} products found');

      final List<ProductModel> products = response
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();

      return products;
    } on PostgrestException catch (e) {
      print('❌ Supabase PostgrestException: ${e.message}');
      throw _handleSupabaseError(e);
    } on Exception catch (e) {
      print('❌ General Exception: $e');
      throw Exception('Failed to search products with query "$query": $e');
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

  /// Get featured products (is_featured = true)
  @override
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10}) async {
    try {
      print('🔍 Fetching featured products');

      final response = await client
          .from(_tableName)
          .select('*')
          .eq('is_active', true)
          .eq('is_featured', true)
          .order('average_rating', ascending: false)
          .limit(limit);

      print('📦 Featured products fetched: ${response.length} products');

      return response
          .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('❌ Error fetching featured products: $e');
      throw Exception('Failed to fetch featured products: $e');
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

      print('⭐ Rating updated for product $productId');
    } catch (e) {
      print('❌ Error updating product rating: $e');
      throw Exception('Failed to update product rating: $e');
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
