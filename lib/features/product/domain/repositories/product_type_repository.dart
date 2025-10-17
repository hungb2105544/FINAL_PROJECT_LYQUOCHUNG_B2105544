import 'package:ecommerce_app/features/product/data/models/product_type_model.dart';

abstract class ProductTypeRepository {
  Future<List<ProductTypeModel>> getAllProductType();
}
