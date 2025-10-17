import 'package:ecommerce_app/features/product/data/models/brand_model.dart';

abstract class BrandRepository {
  Future<List<BrandModel>> getAllBrands();
}
