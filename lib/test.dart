import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  print('Bắt đầu test kết nối Supabase...');
  await SupabaseConfig.initialize();
  final client = SupabaseConfig.client;

  try {
    // Thử query bảng "rank_levels"
    final response = await client.from('rank_levels').select();

    if (response.isNotEmpty) {
      print("Kết nối thành công! Lấy được dữ liệu từ bảng 'rank_levels'");
    } else {
      print(" Kết nối thành công nhưng bảng 'rank_levels' rỗng");
    }
  } catch (e) {
    print("Lỗi kết nối Supabase: $e");
  }

  print('Test hoàn tất');
}
