import 'package:app_links/app_links.dart';
import 'package:flutter/services.dart';
import 'dart:async';

class DeepLinkService {
  static final DeepLinkService _instance = DeepLinkService._internal();
  factory DeepLinkService() => _instance;
  DeepLinkService._internal();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _linkSubscription;

  // Callback khi nhận được deep link
  Function(Uri)? onLinkReceived;

  Future<void> initialize() async {
    try {
      // Xử lý link khi app được mở từ cold start
      final initialLink = await _appLinks.getInitialLink();
      if (initialLink != null) {
        _handleDeepLink(initialLink);
      }

      // Lắng nghe incoming links khi app đang chạy
      _linkSubscription = _appLinks.uriLinkStream.listen(
        _handleDeepLink,
        onError: (err) {
          print('Deep link error: $err');
        },
      );
    } on PlatformException catch (e) {
      print('Failed to get initial link: ${e.message}');
    }
  }

  void _handleDeepLink(Uri uri) {
    print('Received deep link: $uri');

    // Kiểm tra xem có phải link xác thực email không
    if (uri.path.contains('/auth/callback') ||
        uri.fragment.contains('access_token') ||
        uri.queryParameters.containsKey('access_token')) {
      onLinkReceived?.call(uri);
    }
  }

  void dispose() {
    _linkSubscription?.cancel();
  }
}
