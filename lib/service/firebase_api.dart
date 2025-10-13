import 'package:ecommerce_app/features/order/presentation/order_detail_page.dart';
import 'package:ecommerce_app/main.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

const AndroidNotificationChannel defaultChannel = AndroidNotificationChannel(
  'default_channel',
  'Default Notifications',
  description: 'This channel is used for important notifications.',
  importance: Importance.high,
);

Future<void> setupNotificationChannel() async {
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(defaultChannel);
}

class NotificationType {
  static const String order = 'order';
  static const String promotion = 'promotion';
  static const String system = 'system';
}

@pragma('vm:entry-point')
Future<void> handleBackgroundMessage(RemoteMessage message) async {
  if (kDebugMode) {
    print("📩 Background Message");
    print("Title: ${message.notification?.title}");
    print("Body: ${message.notification?.body}");
    print("Data: ${message.data}");
  }
}

class FirebaseApi {
  FirebaseApi._();
  static final FirebaseApi instance = FirebaseApi._();

  final _firebaseMessaging = FirebaseMessaging.instance;
  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;
  bool get isInitialized => _isInitialized;

  Future<void> initNotifications() async {
    if (_isInitialized) {
      if (kDebugMode) print("⚠️ Already initialized");
      return;
    }
    try {
      final settings = await _requestPermission();
      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        if (kDebugMode) print("⚠️ Notification permission denied");
        return;
      }

      await _setupLocalNotifications(); // THÊM MỚI
      await _getFCMToken();
      _setupMessageHandlers();
      _isInitialized = true;
      if (kDebugMode) print("✅ Firebase Messaging initialized");
    } catch (e) {
      if (kDebugMode) print("❌ Init error: $e");
    }
  }

  Future<NotificationSettings> _requestPermission() async {
    return await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  // THÊM MỚI: Setup local notifications với callback
  Future<void> _setupLocalNotifications() async {
    const initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initializationSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // ⭐ KEY: Đăng ký callback khi tap vào notification
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (kDebugMode) {
          print("🔔 Local notification tapped!");
          print("Payload: ${response.payload}");
        }

        if (response.payload != null) {
          _handleNotificationTap(response.payload!);
        }
      },
    );

    if (kDebugMode) print("✅ Local notifications initialized");
  }

  Future<void> _getFCMToken() async {
    _fcmToken = await _firebaseMessaging.getToken();
    if (kDebugMode) print("🔑 FCM Token: $_fcmToken");

    _firebaseMessaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      if (kDebugMode) print("🔄 Token refreshed: $newToken");
    });
  }

  void _setupMessageHandlers() {
    // Background/Terminated
    FirebaseMessaging.onBackgroundMessage(handleBackgroundMessage);

    // Foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Opened from background/terminated
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageNavigation);

    // Initial message (app opened from terminated state)
    _handleInitialMessage();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    if (kDebugMode) {
      print("📱 Foreground Message");
      print("Title: ${message.notification?.title}");
      print("Body: ${message.notification?.body}");
      print("Data: ${message.data}");
    }

    final notification = message.notification;
    if (notification != null) {
      // Tạo payload từ message.data để truyền cho local notification
      final payload = _createPayloadFromData(message.data);

      flutterLocalNotificationsPlugin.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            defaultChannel.id,
            defaultChannel.name,
            channelDescription: defaultChannel.description,
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload, // ⭐ QUAN TRỌNG: Truyền payload
      );
    }
  }

  // THÊM MỚI: Tạo payload string từ message data
  String _createPayloadFromData(Map<String, dynamic> data) {
    // Convert map to JSON string
    final payloadMap = {
      'notification_type': data['notification_type'] ?? '',
      'order_id': data['order_id'] ?? '',
      'order_number': data['order_number'] ?? '',
      'status': data['status'] ?? '',
    };

    // Simple format: type|order_id|order_number|status
    return '${payloadMap['notification_type']}|${payloadMap['order_id']}|${payloadMap['order_number']}|${payloadMap['status']}';
  }

  // THÊM MỚI: Parse payload string
  Map<String, String> _parsePayload(String payload) {
    final parts = payload.split('|');
    return {
      'notification_type': parts.isNotEmpty ? parts[0] : '',
      'order_id': parts.length > 1 ? parts[1] : '',
      'order_number': parts.length > 2 ? parts[2] : '',
      'status': parts.length > 3 ? parts[3] : '',
    };
  }

  // THÊM MỚI: Xử lý khi tap vào local notification
  void _handleNotificationTap(String payload) {
    if (kDebugMode)
      print("👆 Handling notification tap with payload: $payload");

    final data = _parsePayload(payload);
    final notificationType = data['notification_type'];

    // Chờ navigator sẵn sàng
    Future.delayed(const Duration(milliseconds: 300), () {
      if (navigatorKey.currentContext == null) {
        if (kDebugMode) print("⚠️ Context not ready, retrying...");
        Future.delayed(const Duration(milliseconds: 500), () {
          _handleNotificationTap(payload);
        });
        return;
      }

      switch (notificationType) {
        case NotificationType.order:
          _navigateToOrderFromData(data);
          break;
        case NotificationType.promotion:
          _navigateToPromotionFromData(data);
          break;
        case NotificationType.system:
          _navigateToSystemFromData(data);
          break;
        default:
          if (kDebugMode) print("❓ Unknown type: $notificationType");
      }
    });
  }

  Future<void> _handleInitialMessage() async {
    final initialMessage = await _firebaseMessaging.getInitialMessage();
    if (initialMessage != null) {
      if (kDebugMode) {
        print("🚀 Initial message received");
        print("Data: ${initialMessage.data}");
      }
      await Future.delayed(const Duration(milliseconds: 500));
      _handleMessageNavigation(initialMessage);
    }
  }

  void _handleMessageNavigation(RemoteMessage message) {
    if (navigatorKey.currentState == null) {
      if (kDebugMode) print("⚠️ Navigator not ready, retrying...");
      Future.delayed(const Duration(milliseconds: 300), () {
        _handleMessageNavigation(message);
      });
      return;
    }

    final context = navigatorKey.currentContext;
    if (context == null || !context.mounted) {
      if (kDebugMode) print("⚠️ Context not available");
      return;
    }

    final notificationType = message.data['notification_type'] as String?;

    if (kDebugMode) {
      print("🔔 Navigation triggered from FCM");
      print("Type: $notificationType");
      print("Data: ${message.data}");
    }

    switch (notificationType) {
      case NotificationType.order:
        _navigateToOrder(message);
        break;
      case NotificationType.promotion:
        _navigateToPromotion(message);
        break;
      case NotificationType.system:
        _navigateToSystem(message);
        break;
      default:
        if (kDebugMode) print("❓ Unknown type: $notificationType");
    }
  }

  void _navigateToOrder(RemoteMessage message) {
    final orderId = message.data["order_id"];

    if (kDebugMode) {
      print("📦 [_navigateToOrder] Received data:");
      print("   order_id: $orderId");
      print("   Full data: ${message.data}");
    }

    if (orderId == null || orderId.isEmpty) {
      if (kDebugMode) print("⚠️ Missing order_id in message data");
      return;
    }

    if (kDebugMode) {
      print("🚀 Navigating to Order ID: $orderId");
      print("   Navigator ready: ${navigatorKey.currentState != null}");
    }

    try {
      navigatorKey.currentState?.pushNamed(
        OrderDetailPage.route,
        arguments: {"order_id": orderId.toString()},
      );
      if (kDebugMode) print("✅ Navigation command sent");
    } catch (e) {
      if (kDebugMode) print("❌ Navigation error: $e");
    }
  }

  // THÊM MỚI: Navigate từ parsed data
  void _navigateToOrderFromData(Map<String, String> data) {
    final orderId = data["order_id"];
    if (orderId == null || orderId.isEmpty) {
      if (kDebugMode) print("⚠️ Missing order_id in data");
      return;
    }

    if (kDebugMode) print("📦 Navigating to Order ID: $orderId");

    navigatorKey.currentState?.pushNamed(
      OrderDetailPage.route,
      arguments: {"order_id": orderId},
    );
  }

  void _navigateToPromotion(RemoteMessage message) {
    if (kDebugMode) print("🎁 TODO: Navigate to Promotion");
    // TODO: Implement promotion navigation
  }

  void _navigateToPromotionFromData(Map<String, String> data) {
    if (kDebugMode) print("🎁 TODO: Navigate to Promotion from data");
    // TODO: Implement promotion navigation
  }

  void _navigateToSystem(RemoteMessage message) {
    if (kDebugMode) print("⚙️ TODO: Navigate to System");
    // TODO: Implement system notification navigation
  }

  void _navigateToSystemFromData(Map<String, String> data) {
    if (kDebugMode) print("⚙️ TODO: Navigate to System from data");
    // TODO: Implement system notification navigation
  }

  Future<void> deleteToken() async {
    try {
      await _firebaseMessaging.deleteToken();
      _fcmToken = null;
      if (kDebugMode) print("🗑️ Token deleted");
    } catch (e) {
      if (kDebugMode) print("❌ Delete token error: $e");
    }
  }

  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      if (kDebugMode) print("✅ Subscribed to: $topic");
    } catch (e) {
      if (kDebugMode) print("❌ Subscribe error: $e");
    }
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      if (kDebugMode) print("✅ Unsubscribed from: $topic");
    } catch (e) {
      if (kDebugMode) print("❌ Unsubscribe error: $e");
    }
  }
}
