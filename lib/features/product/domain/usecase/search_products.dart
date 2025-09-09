import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';

class SearchProducts {
  final ProductRemoteDataSourceImpl repository;

  SearchProducts(this.repository);

  Future<List<ProductModel>> call(String query) async {
    return await repository.searchProducts(query);
  }
}
