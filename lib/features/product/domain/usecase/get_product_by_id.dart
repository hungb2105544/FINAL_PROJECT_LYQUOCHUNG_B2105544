import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';

class GetProductById {
  final ProductRemoteDataSourceImpl repository;
  GetProductById(this.repository);

  Future<ProductModel> call(String id) async {
    return await repository.getProductById(id);
  }
}
