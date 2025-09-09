import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';

class GetProductsIsActive {
  final ProductRemoteDataSourceImpl repository;

  GetProductsIsActive(this.repository);

  Future<List<ProductModel>> call() async {
    return await repository.getProductsIsActive();
  }
}
