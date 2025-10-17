import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';

class GetProductByBrand {
  final ProductRemoteDataSourceImpl repository;

  GetProductByBrand(this.repository);

  Future<List<ProductModel>> call(String brandId) async {
    final int? id = int.tryParse(brandId);
    if (id == null) {
      throw ArgumentError('Invalid brand ID format');
    }
    final products = await repository.getProductsByBrand(id);
    return products.map((e) => e as ProductModel).toList();
  }
}
