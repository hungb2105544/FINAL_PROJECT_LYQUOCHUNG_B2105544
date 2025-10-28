import 'package:ecommerce_app/features/product/data/models/product_model.dart';

abstract class FavoriteRepository {
  Future<void> addFavorite(int productId);
  Future<void> removeFavorite(int productId);
  Future<List<ProductModel>> getFavoriteProducts();
  Future<Set<int>> getFavoriteProductIds();
}
