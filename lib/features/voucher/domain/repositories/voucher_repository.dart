import 'package:ecommerce_app/features/voucher/data/model/voucher_model.dart';

abstract class VoucherRepository {
  Future<List<VoucherModel>> fetchVouchers();
  Future<List<VoucherModel>> fetchAvailableVouchers(String userId);
  Future<void> saveVoucher(String userId, String voucherId);
}
