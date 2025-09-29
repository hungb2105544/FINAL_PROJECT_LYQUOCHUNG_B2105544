import 'package:dio/dio.dart';

class TransactionSepayApi {
  late Dio dio;
  String? _token;

  TransactionSepayApi({String baseUrl = "https://my.sepay.vn"})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {
            "Content-Type": "application/json",
            "Accept": "application/json",
          },
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_token != null) {
          options.headers["Authorization"] = "Bearer $_token";
        }
        print("→ Request [${options.method}] => ${options.uri}");
        return handler.next(options);
      },
      onResponse: (response, handler) {
        print(
            "← Response [${response.statusCode}] <= ${response.requestOptions.uri}");
        return handler.next(response);
      },
      onError: (DioException e, handler) {
        print("⚠️ Error [${e.response?.statusCode}] => ${e.message}");
        return handler.next(e);
      },
    ));
  }

  // Hàm set token
  void setToken(String token) {
    _token = token;
  }

  Future<Map<String, dynamic>> getTransaction() async {
    final resp = await dio.get("/userapi/transactions/list");
    return Map<String, dynamic>.from(resp.data);
  }

  // API lọc giao dịch theo amount_in
  Future<Map<String, dynamic>> getTransactionWithAmountIn(
      String amountIN) async {
    final resp =
        await dio.get("/userapi/transactions/list?amount_in=$amountIN");
    return Map<String, dynamic>.from(resp.data);
  }
}
