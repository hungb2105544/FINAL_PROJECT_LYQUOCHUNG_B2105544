import 'dart:async';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/auth/bloc/auth_event.dart';
import 'package:ecommerce_app/features/auth/bloc/auth_state.dart';
import 'package:ecommerce_app/features/auth/service/session_manager.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthBloc extends Bloc<AuthEvent, AuthenState> {
  AuthBloc() : super(const AuthenState.initial()) {
    on<LoginEvent>(_onLogin);
    on<LogoutEvent>(_onLogout);
    on<RestoreSessionEvent>(_onRestore);
    on<RegisterEvent>(_onRegister);
    on<HandleAuthCallbackEvent>(_onHandleAuthCallback);
    on<ResendVerificationEvent>(_onResendVerification);
    on<ResetPasswordEvent>(_onResetPassword);
    on<UpdatePasswordEvent>(_onUpdatePassword);
    on<CheckEmailVerificationEvent>(_onCheckEmailVerification);
    on<LoginWithGoogle>(_loginWithGoogle);
  }

  // ==================== DEVICE & FCM TOKEN MANAGEMENT ====================

  /// Lấy Device ID duy nhất cho mỗi thiết bị
  Future<String> _getDeviceId() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ??
            "unknown_ios_${DateTime.now().millisecondsSinceEpoch}";
      } else {
        return "unknown_device_${DateTime.now().millisecondsSinceEpoch}";
      }
    } catch (e) {
      print("❌ Lỗi khi lấy Device ID: $e");
      return "error_device_${DateTime.now().millisecondsSinceEpoch}";
    }
  }

  /// Lấy tên thiết bị để hiển thị
  Future<String> _getDeviceName() async {
    try {
      final deviceInfo = DeviceInfoPlugin();
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return "${androidInfo.brand} ${androidInfo.model}";
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return "${iosInfo.name} (${iosInfo.model})";
      }
      return "Unknown Device";
    } catch (e) {
      return "Unknown Device";
    }
  }

  /// Lấy platform (Android/iOS)
  String _getPlatform() {
    if (Platform.isAndroid) return 'android';
    if (Platform.isIOS) return 'ios';
    return 'unknown';
  }

  /// Lưu FCM token vào database khi đăng nhập thành công
  Future<void> _saveFcmToken(String userId) async {
    try {
      final client = SupabaseConfig.client;
      final fcmToken = await FirebaseMessaging.instance.getToken();
      final deviceId = await _getDeviceId();
      final deviceName = await _getDeviceName();
      final platform = _getPlatform();

      if (fcmToken == null || fcmToken.isEmpty) {
        print("⚠️ FCM token null hoặc rỗng, bỏ qua lưu token");
        return;
      }

      // Upsert token vào database
      await client.from('user_devices').upsert(
        {
          'user_id': userId,
          'fcm_token': fcmToken,
          'device_id': deviceId,
          'device_name': deviceName,
          'platform': platform,
          'is_active': true,
          'last_active_at': DateTime.now().toIso8601String(),
        },
        onConflict: 'user_id,device_id', // Tránh trùng lặp
      );

      print("✅ Đã lưu FCM token thành công");
      print("   📱 Device: $deviceName ($deviceId)");
      print("   🔑 Token: ${fcmToken.substring(0, 20)}...");
    } catch (e) {
      print("❌ Lỗi khi lưu FCM token: $e");
      // Không throw error để không ảnh hưởng đến flow đăng nhập
    }
  }

  /// Vô hiệu hóa FCM token khi đăng xuất
  Future<void> _deactivateFcmToken(String userId) async {
    try {
      final client = SupabaseConfig.client;
      final deviceId = await _getDeviceId();

      await client
          .from('user_devices')
          .update({'is_active': false})
          .eq('user_id', userId)
          .eq('device_id', deviceId);

      print("🚪 Đã vô hiệu hóa FCM token khi logout");
    } catch (e) {
      print("❌ Lỗi khi deactivate FCM token: $e");
      // Không throw error
    }
  }

  /// Xóa tất cả token cũ của user trên thiết bị này (cleanup)
  Future<void> _cleanupOldTokens(String userId) async {
    try {
      final client = SupabaseConfig.client;
      final deviceId = await _getDeviceId();

      // Lấy danh sách token cũ (inactive hoặc quá 30 ngày không active)
      final oldDate =
          DateTime.now().subtract(const Duration(days: 30)).toIso8601String();

      await client
          .from('user_devices')
          .delete()
          .eq('user_id', userId)
          .eq('device_id', deviceId)
          .or('is_active.eq.false,last_active_at.lt.$oldDate');

      print("🧹 Đã dọn dẹp token cũ");
    } catch (e) {
      print("⚠️ Lỗi khi cleanup token: $e");
    }
  }

  // ==================== AUTHENTICATION HANDLERS ====================

  /// ĐĂNG KÝ TÀI KHOẢN MỚI
  Future<void> _onRegister(
      RegisterEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      if (!_validateRegistrationData(event.email, event.password)) {
        emit(const AuthenState.error('Email hoặc mật khẩu không hợp lệ.'));
        return;
      }

      final client = SupabaseConfig.client;
      final response = await client.auth.signUp(
        email: event.email.trim().toLowerCase(),
        password: event.password,
        emailRedirectTo: 'ecommerceapp://auth/callback',
        data: {
          'registration_source': 'mobile_app',
          'registration_timestamp': DateTime.now().toIso8601String(),
          'app_name': 'Ecommerce App',
          'full_name': event.email.split('@')[0],
        },
      );

      final user = response.user;
      if (user == null) {
        emit(const AuthenState.error(
            'Không thể tạo tài khoản. Vui lòng thử lại.'));
        return;
      }

      // Đảm bảo profile được tạo
      try {
        await Future.delayed(const Duration(seconds: 1));
        await client
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .single()
            .timeout(const Duration(seconds: 5));
        print('✅ Profile created successfully');
      } catch (e) {
        print('⚠️ Profile might not be created: $e');
      }

      if (user.emailConfirmedAt == null) {
        emit(const AuthenState.emailVerificationRequired());
      } else {
        final session = response.session;
        if (session != null) {
          await SessionManager.saveSession(session);

          // Lưu FCM token sau khi đăng ký thành công
          await _saveFcmToken(user.id);

          emit(AuthenState.authenticated(user.id));
        } else {
          emit(const AuthenState.emailVerificationRequired());
        }
      }
    } on AuthException catch (e) {
      emit(AuthenState.error(_getLocalizedAuthError(e)));
    } catch (e) {
      print('❌ Registration error: $e');
      if (e.toString().contains('unexpected_failure') ||
          e.toString().contains('Database error')) {
        emit(const AuthenState.error(
            'Lỗi hệ thống. Vui lòng thử lại sau ít phút.'));
      } else {
        emit(const AuthenState.error(
            'Có lỗi xảy ra khi đăng ký. Vui lòng thử lại.'));
      }
    }
  }

  /// ĐĂNG NHẬP BẰNG EMAIL & PASSWORD
  Future<void> _onLogin(LoginEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      if (!_validateLoginData(event.email, event.password)) {
        emit(const AuthenState.error('Email hoặc mật khẩu không hợp lệ.'));
        return;
      }

      final client = SupabaseConfig.client;
      final response = await client.auth.signInWithPassword(
        email: event.email.trim().toLowerCase(),
        password: event.password,
      );

      final session = response.session;
      final user = response.user;

      if (session != null && user != null) {
        if (user.emailConfirmedAt == null) {
          emit(const AuthenState.emailVerificationRequired());
        } else {
          await SessionManager.saveSession(session);

          // Lưu FCM token ngay sau khi đăng nhập thành công
          await _saveFcmToken(user.id);

          // Dọn dẹp token cũ (chạy background, không chờ)
          _cleanupOldTokens(user.id);

          emit(AuthenState.authenticated(user.id));
        }
      } else {
        emit(const AuthenState.error('Thông tin đăng nhập không chính xác.'));
      }
    } on AuthException catch (e) {
      emit(AuthenState.error(_getLocalizedAuthError(e)));
    } catch (e) {
      print('❌ Login error: $e');
      emit(const AuthenState.error(
          'Có lỗi xảy ra khi đăng nhập. Vui lòng thử lại.'));
    }
  }

  /// ĐĂNG NHẬP BẰNG GOOGLE
  Future<void> _loginWithGoogle(
      LoginWithGoogle event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      final googleSignIn = GoogleSignIn(
        serverClientId:
            "152762888438-1hpuulu1khn4iam4lt1m1uo5mtv87pbj.apps.googleusercontent.com",
      );

      final googleUser =
          await googleSignIn.signInSilently() ?? await googleSignIn.signIn();

      if (googleUser == null) {
        print("⚠️ Google user null - người dùng hủy đăng nhập");
        emit(const AuthenState.unauthenticated());
        return;
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        emit(const AuthenState.error('Không thể lấy token từ Google'));
        return;
      }

      final client = SupabaseConfig.client;
      final response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      final session = response.session;
      final user = response.user;

      if (session != null && user != null) {
        await SessionManager.saveSession(session);

        // Tạo profile nếu chưa có
        try {
          final profile = await client
              .from('user_profiles')
              .select()
              .eq('id', user.id)
              .maybeSingle()
              .timeout(const Duration(seconds: 3));

          if (profile == null) {
            await client.from('user_profiles').insert({
              'id': user.id,
              'email': user.email,
              'full_name': googleUser.displayName ?? user.email?.split('@')[0],
              'avatar_url': googleUser.photoUrl,
              'registration_source': 'google_oauth',
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          print('⚠️ Lỗi khi tạo/kiểm tra profile: $e');
        }

        // Lưu FCM token sau khi đăng nhập Google thành công
        await _saveFcmToken(user.id);

        // Cleanup token cũ
        _cleanupOldTokens(user.id);

        emit(AuthenState.authenticated(user.id));
      } else {
        emit(const AuthenState.error('Đăng nhập Google thất bại'));
      }
    } on AuthException catch (e) {
      emit(AuthenState.error(_getLocalizedAuthError(e)));
    } catch (e) {
      print('❌ Google login error: $e');
      emit(const AuthenState.error('Có lỗi xảy ra khi đăng nhập với Google'));
    }
  }

  /// ĐĂNG XUẤT
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      final userId = SupabaseConfig.client.auth.currentUser?.id;

      // Vô hiệu hóa FCM token trước khi logout
      if (userId != null) {
        await _deactivateFcmToken(userId);
      }

      await SupabaseConfig.client.auth.signOut();
      await SessionManager.clearSession();

      emit(const AuthenState.unauthenticated());
    } catch (e) {
      print('❌ Logout error: $e');
      emit(const AuthenState.unauthenticated());
    }
  }

  /// KHÔI PHỤC SESSION
  Future<void> _onRestore(
      RestoreSessionEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      final client = SupabaseConfig.client;

      // Thử refresh session
      try {
        final currentSession = client.auth.currentSession;
        if (currentSession != null) {
          final refreshResponse = await client.auth.refreshSession();
          if (refreshResponse.session != null) {
            await SessionManager.saveSession(refreshResponse.session!);
          }
        }
      } catch (e) {
        print("⚠️ Session refresh failed: $e");
      }

      final session = await SessionManager.restoreSession();

      if (session != null) {
        final user = client.auth.currentUser;

        if (user != null && !session.isExpired) {
          if (user.emailConfirmedAt != null) {
            // Cập nhật FCM token khi restore session
            await _saveFcmToken(user.id);

            emit(AuthenState.authenticated(user.id));
          } else {
            emit(const AuthenState.emailVerificationRequired());
          }
        } else {
          await SessionManager.clearSession();
          await client.auth.signOut();
          emit(const AuthenState.unauthenticated());
        }
      } else {
        emit(const AuthenState.unauthenticated());
      }
    } catch (e) {
      print('❌ Session restore error: $e');
      await SessionManager.clearSession();
      await SupabaseConfig.client.auth.signOut();
      emit(const AuthenState.unauthenticated());
    }
  }

  /// KIỂM TRA XÁC THỰC EMAIL
  Future<void> _onCheckEmailVerification(
      CheckEmailVerificationEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      final client = SupabaseConfig.client;
      final refreshResponse = await client.auth.refreshSession();

      if (refreshResponse.session != null && refreshResponse.user != null) {
        await SessionManager.saveSession(refreshResponse.session!);
        final user = refreshResponse.user!;

        if (user.emailConfirmedAt != null) {
          // Lưu FCM token sau khi verify email thành công
          await _saveFcmToken(user.id);

          emit(AuthenState.authenticated(user.id));
        } else {
          emit(const AuthenState.emailVerificationRequired());
        }
      } else {
        emit(const AuthenState.error("Không thể kiểm tra trạng thái xác thực"));
      }
    } catch (e) {
      print('❌ Check email verification error: $e');
      emit(const AuthenState.error("Lỗi kiểm tra xác thực"));
    }
  }

  /// XỬ LÝ CALLBACK TỪ DEEP LINK
  Future<void> _onHandleAuthCallback(
      HandleAuthCallbackEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      final client = SupabaseConfig.client;
      final response = await client.auth.setSession(event.accessToken);

      if (response.session != null && response.user != null) {
        await SessionManager.saveSession(response.session!);

        if (response.user!.emailConfirmedAt != null) {
          // Lưu FCM token sau khi callback thành công
          await _saveFcmToken(response.user!.id);

          emit(AuthenState.authenticated(response.user!.id));
        } else {
          emit(const AuthenState.emailVerificationRequired());
        }
      } else {
        emit(const AuthenState.error(
            'Không thể xác thực email. Vui lòng thử lại.'));
      }
    } catch (e) {
      print('❌ Auth callback error: $e');
      emit(AuthenState.error('Lỗi xác thực email: ${e.toString()}'));
    }
  }

  /// GỬI LẠI EMAIL XÁC THỰC
  Future<void> _onResendVerification(
      ResendVerificationEvent event, Emitter<AuthenState> emit) async {
    try {
      final client = SupabaseConfig.client;

      await client.auth.resend(
        type: OtpType.signup,
        email: event.email,
        emailRedirectTo: 'ecommerceapp://auth/callback',
      );
    } on AuthException catch (e) {
      emit(AuthenState.error(_getLocalizedAuthError(e)));
    } catch (e) {
      print('❌ Resend verification error: $e');
      emit(const AuthenState.error('Không thể gửi lại email xác thực.'));
    }
  }

  /// RESET MẬT KHẨU
  Future<void> _onResetPassword(
      ResetPasswordEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      final client = SupabaseConfig.client;
      await client.auth.resetPasswordForEmail(
        event.email,
        redirectTo: 'ecommerceapp://auth/reset-password',
      );

      emit(const AuthenState.passwordResetSent());
    } on AuthException catch (e) {
      emit(AuthenState.error(_getLocalizedAuthError(e)));
    } catch (e) {
      print('❌ Reset password error: $e');
      emit(const AuthenState.error('Không thể gửi email reset mật khẩu.'));
    }
  }

  /// CẬP NHẬT MẬT KHẨU
  Future<void> _onUpdatePassword(
      UpdatePasswordEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      final client = SupabaseConfig.client;
      final response = await client.auth.updateUser(
        UserAttributes(password: event.newPassword),
      );

      if (response.user != null) {
        emit(const AuthenState.passwordUpdated());
      } else {
        emit(const AuthenState.error('Không thể cập nhật mật khẩu.'));
      }
    } on AuthException catch (e) {
      emit(AuthenState.error(_getLocalizedAuthError(e)));
    } catch (e) {
      print('❌ Update password error: $e');
      emit(const AuthenState.error('Có lỗi xảy ra khi cập nhật mật khẩu.'));
    }
  }

  // ==================== VALIDATION & ERROR HANDLING ====================

  bool _validateRegistrationData(String email, String password) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) return false;
    if (password.length < 6) return false;
    return true;
  }

  bool _validateLoginData(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) return false;
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  String _getLocalizedAuthError(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('email not confirmed') ||
        message.contains('email_not_confirmed')) {
      return 'Email chưa được xác thực. Vui lòng kiểm tra hộp thư.';
    } else if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return 'Email hoặc mật khẩu không chính xác.';
    } else if (message.contains('already registered') ||
        message.contains('already exists')) {
      return 'Email này đã được đăng ký.';
    } else if (message.contains('invalid email')) {
      return 'Email không hợp lệ.';
    } else if (message.contains('password')) {
      if (message.contains('too short'))
        return 'Mật khẩu quá ngắn (tối thiểu 6 ký tự).';
      return 'Mật khẩu không hợp lệ.';
    } else if (message.contains('too many requests') ||
        message.contains('rate limit')) {
      return 'Quá nhiều yêu cầu. Vui lòng đợi một lúc.';
    } else if (message.contains('network') || message.contains('connection')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
    } else if (message.contains('user not found')) {
      return 'Không tìm thấy tài khoản với email này.';
    } else if (message.contains('token')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    } else if (message.contains('google') || message.contains('oauth')) {
      if (message.contains('cancelled') || message.contains('user_cancelled')) {
        return 'Đăng nhập Google đã bị hủy';
      } else if (message.contains('invalid_token')) {
        return 'Token Google không hợp lệ. Vui lòng thử lại.';
      } else if (message.contains('configuration')) {
        return 'Cấu hình Google OAuth chưa đúng.';
      }
      return 'Lỗi đăng nhập Google. Vui lòng thử lại.';
    }

    return e.message.isNotEmpty
        ? e.message
        : 'Có lỗi xảy ra. Vui lòng thử lại.';
  }

  // ==================== UTILITY METHODS ====================

  bool get isAuthenticated => state.status == AuthStatus.authenticated;
  bool get isLoading => state.status == AuthStatus.loading;
  String? get currentUserId => state.userId;

  /// Refresh token nếu cần
  Future<void> refreshTokenIfNeeded() async {
    try {
      final session = SupabaseConfig.client.auth.currentSession;
      if (session != null && session.isExpired) {
        final response = await SupabaseConfig.client.auth.refreshSession();
        if (response.session != null) {
          await SessionManager.saveSession(response.session!);
        }
      }
    } catch (e) {
      print('❌ Token refresh error: $e');
      add(LogoutEvent());
    }
  }

  /// Cập nhật FCM token thủ công (ví dụ: khi token refresh)
  Future<void> updateFcmToken() async {
    try {
      final userId = SupabaseConfig.client.auth.currentUser?.id;
      if (userId != null) {
        await _saveFcmToken(userId);
      }
    } catch (e) {
      print('❌ Update FCM token error: $e');
    }
  }

  @override
  Future<void> close() async {
    return super.close();
  }
}
