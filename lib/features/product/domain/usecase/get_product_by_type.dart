import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';

class GetProductByType {
  final ProductRemoteDataSourceImpl repository;
  GetProductByType(this.repository);

  Future<List<ProductModel>> call(String typeId) async {
    return await repository.getProductsByType(typeId);
  }
}
