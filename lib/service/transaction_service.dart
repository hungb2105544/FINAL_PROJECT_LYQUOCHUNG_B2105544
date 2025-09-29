import 'package:ecommerce_app/features/order/data/model/transaction_model.dart';
import 'package:ecommerce_app/service/transaction_Sepay_Api.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TransactionService {
  final api = TransactionSepayApi();
  final token = dotenv.env['CLIENT_TOKEN_SEPAY'] ?? "";
  TransactionService() {
    api.setToken(token);
  }

  Future<List<TransactionModel>> getAllTransaction() async {
    try {
      final response = await api.getTransaction();
      final List<dynamic> data = response["transactions"] ?? [];
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<TransactionModel>> getAllTransactionWithAmounIn(
      String amountIn) async {
    try {
      final response = await api.getTransactionWithAmountIn(amountIn);
      final List<dynamic> data = response["transactions"] ?? [];
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }
}
