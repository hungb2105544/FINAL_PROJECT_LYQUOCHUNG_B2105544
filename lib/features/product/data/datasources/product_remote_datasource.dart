import 'package:ecommerce_app/features/product/data/models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProductsIsActive(
      {int page = 1, int limit = 20});
  Future<ProductModel> getProductById(String id);
  Future<List<ProductModel>> searchProducts(String query);
  Future<List<ProductModel>> getProductsByType(String type_id);
  Future<List<ProductModel>> getFeaturedProducts({int limit = 10});
}
