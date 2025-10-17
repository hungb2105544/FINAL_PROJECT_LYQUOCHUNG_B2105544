import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/product/data/models/brand_model.dart';
import 'package:ecommerce_app/features/product/domain/repositories/brand_repository.dart';

class BrandRepositoryImpl implements BrandRepository {
  final _supabase = SupabaseConfig.client;
  static const String _tableName = 'brands';

  @override
  Future<List<BrandModel>> getAllBrands() async {
    try {
      final response = await _supabase.from(_tableName).select('*');

      if (response.isEmpty) {
        return [];
      }

      final brands =
          (response as List).map((json) => BrandModel.fromJson(json)).toList();
      return brands;
    } catch (e) {
      throw Exception('Failed to get all brands: $e');
    }
  }
}
