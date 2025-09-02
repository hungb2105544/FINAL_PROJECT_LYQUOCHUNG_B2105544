import 'package:ecommerce_app/features/auth/bloc/auth_bloc.dart';
import 'package:ecommerce_app/features/auth/bloc/auth_event.dart';
import 'package:ecommerce_app/service/deep_link_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

class AuthDeepLinkHandler {
  static void initialize(BuildContext context) {
    final deepLinkService = DeepLinkService();

    deepLinkService.onLinkReceived = (Uri uri) {
      _handleAuthCallback(context, uri);
    };
  }

  static void _handleAuthCallback(BuildContext context, Uri uri) {
    // Xử lý callback từ Supabase
    if (uri.path.contains('/auth/callback') || uri.fragment.isNotEmpty) {
      // Extract access token từ URL
      String? accessToken;
      String? refreshToken;

      // Kiểm tra trong fragment (thường cho implicit flow)
      if (uri.fragment.isNotEmpty) {
        final fragment = Uri.parse('?${uri.fragment}');
        accessToken = fragment.queryParameters['access_token'];
        refreshToken = fragment.queryParameters['refresh_token'];
      }

      // Kiểm tra trong query parameters
      if (accessToken == null) {
        accessToken = uri.queryParameters['access_token'];
        refreshToken = uri.queryParameters['refresh_token'];
      }

      if (accessToken != null) {
        // Gọi event để xử lý session
        context.read<AuthBloc>().add(HandleAuthCallbackEvent(
              accessToken: accessToken,
              refreshToken: refreshToken,
            ));

        // Hiển thị thông báo
        _showVerificationSuccess(context);
      }
    }
  }

  static void _showVerificationSuccess(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Email đã được xác thực thành công!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }
}
