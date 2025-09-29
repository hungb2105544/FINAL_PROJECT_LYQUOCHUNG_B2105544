import 'package:ecommerce_app/service/transaction_Sepay_Api.dart';

void main() async {
  final service = TransactionSepayApi();

  service.setToken(
      "QEGBS9D2IXYK3OBL1BRLWEHJSKZASHYRZO1IBVHWFMC7Y37WU2X6DXWP0MPMGL5G");

  try {
    print("🔎 Lấy toàn bộ giao dịch...");
    final allTransactions = await service.getTransaction();
    print("✅ Transactions: $allTransactions");

    print("🔎 Lấy giao dịch theo amount_in...");
    final filtered = await service.getTransactionWithAmountIn("100000");
    print("✅ Filtered Transactions: $filtered");
  } catch (e) {
    print("❌ Có lỗi: $e");
  }
}
