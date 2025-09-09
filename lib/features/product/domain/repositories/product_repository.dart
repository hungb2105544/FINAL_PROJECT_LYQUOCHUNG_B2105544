import 'package:ecommerce_app/features/product/domain/entities/product.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({int page = 1, int limit = 20});
  Future<Product> getProductById(String id);
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> getProductsByType(int type_id);
  Stream<List<Product>> watchFavoriteProducts();
  Future<void> addToFavorites(String productId);
  Future<void> removeFromFavorites(String productId);
}
