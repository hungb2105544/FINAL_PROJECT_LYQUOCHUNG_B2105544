// import 'package:ecommerce_app/features/product/data/models/product_model.dart';
// import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';

// class GetProductsIsActive {
//   final ProductRemoteDataSourceImpl repository;

//   GetProductsIsActive(this.repository);

//   Future<List<ProductModel>> call() async {
//     return await repository.getProductsIsActive();
//   }
// }
import 'package:ecommerce_app/features/product/data/models/product_model.dart';
import 'package:ecommerce_app/features/product/data/repositories/product_repository_impl.dart';

class GetProductsIsActive {
  final ProductRemoteDataSourceImpl repository;

  GetProductsIsActive(this.repository);

  /// Bây giờ call hỗ trợ forceRefresh, page, limit
  Future<List<ProductModel>> call({
    int page = 1,
    int limit = 20,
    bool forceRefresh = false,
  }) async {
    return await repository.getProductsIsActive(
      page: page,
      limit: limit,
      forceRefresh: forceRefresh,
    );
  }
}
