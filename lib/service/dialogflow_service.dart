import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;

class DialogflowService {
  static Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      // ✅ Đọc credentials
      final serviceAccount = json.decode(
        await rootBundle.loadString('assets/credentials/dialogflow-key.json'),
      );

      final accountCredentials =
          ServiceAccountCredentials.fromJson(serviceAccount);
      final scopes = ['https://www.googleapis.com/auth/dialogflow'];
      final client = await clientViaServiceAccount(accountCredentials, scopes);

      // ✅ Gửi request detectIntent
      final projectId = serviceAccount['project_id'];
      final sessionId = 'flutter-session-001';
      final url = Uri.parse(
        'https://dialogflow.googleapis.com/v2/projects/$projectId/agent/sessions/$sessionId:detectIntent',
      );

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
        return {"text": "Lỗi khi kết nối Dialogflow"};
      }

      final decoded = jsonDecode(response.body);
      final result = decoded['queryResult'] ?? {};
      String text = result['fulfillmentText'] ?? "";

      if (text.isEmpty) {
        final messages = result['fulfillmentMessages'] ?? [];
        for (var msg in messages) {
          if (msg['text'] != null &&
              msg['text']['text'] != null &&
              msg['text']['text'].isNotEmpty) {
            text = msg['text']['text'][0];
            break;
          }
        }
      }

      // ✅ Tìm object JSON trong payload
      Map<String, dynamic>? payloadObj;
      final messages = result['fulfillmentMessages'] ?? [];
      for (var msg in messages) {
        if (msg['payload'] != null && msg['payload']['object'] != null) {
          payloadObj = Map<String, dynamic>.from(msg['payload']['object']);
          break;
        }
      }

      return {
        "text": text.isNotEmpty ? text : "Mình chưa hiểu ý bạn 😅",
        "object": payloadObj,
      };
    } catch (e) {
      print("❌ Lỗi khi gọi Dialogflow: $e");
      return {"text": "Đã xảy ra lỗi khi kết nối tới chatbot 😢"};
    }
  }
}
