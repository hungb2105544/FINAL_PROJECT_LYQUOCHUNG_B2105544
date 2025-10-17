import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/product/data/models/product_type_model.dart';
import 'package:ecommerce_app/features/product/domain/repositories/product_type_repository.dart';

class ProductTypeRepositoryImpl implements ProductTypeRepository {
  final _supabase = SupabaseConfig.client;

  @override
  Future<List<ProductTypeModel>> getAllProductType() async {
    try {
      final response = await _supabase.from('product_types').select('*');

      print('🔍 ProductType Response: $response'); // THÊM LOG NÀY

      if (response == null || response.isEmpty) {
        print('⚠️ No product types found');
        return [];
      }

      final productTypes = (response as List)
          .map((data) => ProductTypeModel.fromJson(data))
          .toList();

      print('✅ Loaded ${productTypes.length} product types');
      return productTypes;
    } catch (e) {
      print('❌ Error fetching product types: $e');
      throw Exception('Không thể lấy danh sách loại sản phẩm: $e');
    }
  }
}
