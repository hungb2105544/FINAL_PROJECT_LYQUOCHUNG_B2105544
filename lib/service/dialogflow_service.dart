// import 'dart:convert';
// import 'dart:io';
// import 'package:http/http.dart' as http;
// import 'package:googleapis_auth/auth_io.dart';

// class DialogflowService {
//   static Future<String> sendMessage(String message) async {
//     final serviceAccount = json.decode(
//       await File('assets/credentials/dialogflow-key.json').readAsString(),
//     );

//     final accountCredentials =
//         ServiceAccountCredentials.fromJson(serviceAccount);
//     final scopes = ['https://www.googleapis.com/auth/dialogflow'];

//     final client = await clientViaServiceAccount(accountCredentials, scopes);

//     final projectId = serviceAccount['project_id'];
//     final sessionId = 'flutter-session-001'; // Có thể random
//     final url = Uri.parse(
//         'https://dialogflow.googleapis.com/v2/projects/$projectId/agent/sessions/$sessionId:detectIntent');

//     final response = await client.post(
//       url,
//       headers: {'Content-Type': 'application/json; charset=utf-8'},
//       body: jsonEncode({
//         "queryInput": {
//           "text": {"text": message, "languageCode": "vi"}
//         }
//       }),
//     );

//     client.close();

//     final decoded = jsonDecode(response.body);
//     return decoded['queryResult']?['fulfillmentText'] ??
//         "Tôi chưa hiểu ý bạn 😅";
//   }
// }
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/auth_io.dart';

class DialogflowService {
  static Future<String> sendMessage(String message) async {
    try {
      // ✅ Đọc file JSON từ assets (Flutter bundle)
      final serviceAccount = json.decode(
        await rootBundle.loadString('assets/credentials/dialogflow-key.json'),
      );

      // ✅ Xác thực với Dialogflow
      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccount);
      final scopes = ['https://www.googleapis.com/auth/dialogflow'];

      final client = await clientViaServiceAccount(accountCredentials, scopes);

      // ✅ Gửi yêu cầu detectIntent
      final projectId = serviceAccount['project_id'];
      final sessionId = 'flutter-session-001'; // có thể random
      final url = Uri.parse(
          'https://dialogflow.googleapis.com/v2/projects/$projectId/agent/sessions/$sessionId:detectIntent');

      final response = await client.post(
        url,
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode({
          "queryInput": {
            "text": {"text": message, "languageCode": "vi"}
          }
        }),
      );

      client.close();

      if (response.statusCode != 200) {
        print("❌ Dialogflow Error: ${response.statusCode} ${response.body}");
        return "Lỗi khi kết nối Dialogflow (${response.statusCode})";
      }

      final decoded = jsonDecode(response.body);
      final reply = decoded['queryResult']?['fulfillmentText'] ?? "";
      return reply.isNotEmpty ? reply : "Tôi chưa hiểu ý bạn 😅";
    } catch (e) {
      print("❌ Lỗi khi gọi Dialogflow: $e");
      return "Đã xảy ra lỗi khi kết nối tới chatbot 😢";
    }
  }
}
