import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/voucher/data/model/voucher_model.dart';
import 'package:ecommerce_app/features/voucher/domain/repositories/voucher_repository.dart';

class VoucherRepositoryImpl implements VoucherRepository {
  final client = SupabaseConfig.client;

  @override
  Future<List<VoucherModel>> fetchVouchers() async {
    try {
      final data = await client
          .from('vouchers')
          .select('*, user_vouchers!left(voucher_id)')
          .eq('is_active', true)
          .gt('valid_to', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      return (data as List).map((json) {
        final voucher = VoucherModel.fromJson(json);
        // Check if this voucher is saved by checking if user_vouchers array is not empty
        voucher.isSaved = (json['user_vouchers'] as List).isNotEmpty;
        return voucher;
      }).toList();
    } catch (e, stacktrace) {
      print("Error fetching vouchers: $e");
      print(stacktrace);
      return [];
    }
  }

  @override
  Future<List<VoucherModel>> fetchAvailableVouchers(String userId) async {
    try {
      final data = await client
          .from('vouchers')
          .select('''
            *, 
            user_vouchers!left(
              id, 
              user_id, 
              is_used
            )
          ''')
          .eq('is_active', true)
          .eq('user_vouchers.user_id', userId)
          .gt('valid_to', DateTime.now().toIso8601String())
          .order('created_at', ascending: false);

      return (data as List).map((json) {
        final voucher = VoucherModel.fromJson(json);

        // Check if user has saved this voucher
        final userVouchers = json['user_vouchers'] as List?;
        voucher.isSaved = userVouchers != null &&
            userVouchers.isNotEmpty &&
            userVouchers.any((uv) => uv['user_id'] == userId);

        return voucher;
      }).toList();
    } catch (e, stacktrace) {
      print("Error fetching vouchers in repositories: $e");
      print(stacktrace);
      return [];
    }
  }

  @override
  Future<void> saveVoucher(String userId, String voucherId) async {
    try {
      // Check if user already saved this voucher
      final existing = await client
          .from('user_vouchers')
          .select('id')
          .eq('user_id', userId)
          .eq('voucher_id', int.parse(voucherId))
          .maybeSingle();

      if (existing != null) {
        throw Exception('Voucher already saved');
      }

      // Insert new user_voucher
      final result = await client.from('user_vouchers').insert({
        'user_id': userId, // This should be UUID type
        'voucher_id':
            int.parse(voucherId), // Convert string to int for bigint field
      }).select();

      print("Voucher saved successfully: $result");
    } catch (e, stacktrace) {
      print("Error saving voucher: $e");
      print(stacktrace);

      // More detailed error handling
      if (e.toString().contains('row-level security policy')) {
        throw Exception('Không có quyền lưu voucher. Vui lòng đăng nhập lại.');
      } else if (e.toString().contains('duplicate key')) {
        throw Exception('Bạn đã lưu voucher này rồi.');
      } else {
        throw Exception('Lỗi lưu voucher: ${e.toString()}');
      }
    }
  }

  // Additional method to get user's saved vouchers
  Future<List<VoucherModel>> fetchUserSavedVouchers(String userId) async {
    try {
      final data = await client
          .from('vouchers')
          .select('''
            *, 
            user_vouchers!inner(
              id,
              user_id,
              is_used,
              assigned_at
            )
          ''')
          .eq('is_active', true)
          .eq('user_vouchers.user_id', userId)
          .eq('user_vouchers.is_used', false)
          .gt('valid_to', DateTime.now().toIso8601String())
          .order('user_vouchers.assigned_at', ascending: false);

      return (data as List).map((json) {
        final voucher = VoucherModel.fromJson(json);
        voucher.isSaved = true; // All vouchers in this query are saved
        return voucher;
      }).toList();
    } catch (e, stacktrace) {
      print("Error fetching user saved vouchers: $e");
      print(stacktrace);
      return [];
    }
  }
}
