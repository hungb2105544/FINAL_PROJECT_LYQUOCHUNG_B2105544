import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/domain/repositories/favorite_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FavoriteRepositoryImpl implements FavoriteRepository {
  final SupabaseClient _client;
  static const String _tableName = 'wishlists';

  FavoriteRepositoryImpl(this._client);

  String? get _userId => _client.auth.currentUser?.id;

  @override
  Future<void> addFavorite(int productId) async {
    if (_userId == null) throw const AuthException('User not logged in');
    try {
      await _client.from(_tableName).insert({
        'user_id': _userId,
        'product_id': productId,
      });
    } catch (e) {
      if (e is PostgrestException && e.code == '23505') {
        print('Product $productId already in favorites.');
        return;
      }
      print('Error adding favorite: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFavorite(int productId) async {
    if (_userId == null) throw const AuthException('User not logged in');
    try {
      await _client
          .from(_tableName)
          .delete()
          .eq('user_id', _userId!)
          .eq('product_id', productId);
    } catch (e) {
      print('Error removing favorite: $e');
      rethrow;
    }
  }

  @override
  Future<Set<int>> getFavoriteProductIds() async {
    if (_userId == null) return {};
    try {
      final response = await _client
          .from(_tableName)
          .select('product_id')
          .eq('user_id', _userId!);

      return response.map((item) => item['product_id'] as int).toSet();
    } catch (e) {
      print('Error getting favorite IDs: $e');
      return {};
    }
  }

  @override
  Future<List<ProductModel>> getFavoriteProducts() async {
    if (_userId == null) return [];
    try {
      // Sử dụng RPC function để join và lấy dữ liệu sản phẩm
      final response =
          await _client.rpc('get_user_wishlist', params: {'uid': _userId});
      print('Favorite products response: $response');

      // The RPC returns a single object with a 'wishlists' key containing the list of products.
      if (response == null ||
          response is! Map ||
          !response.containsKey('wishlists')) {
        return [];
      }

      final wishlistsData = response['wishlists'];

      if (wishlistsData == null || wishlistsData is! List) {
        return [];
      }

      final products = (wishlistsData as List)
          .map((productJson) =>
              ProductModel.fromJson(productJson as Map<String, dynamic>))
          .toList();

      return products;
    } catch (e) {
      print('Error getting favorite products: $e');
      rethrow;
    }
  }
}
