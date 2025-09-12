import 'dart:async';

import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/auth/bloc/auth_event.dart';
import 'package:ecommerce_app/features/auth/bloc/auth_state.dart';
import 'package:ecommerce_app/features/auth/service/session_manager.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
    on<LoginWithGoogle>(_LogininwithGoogle);
  }
  Future<void> _LogininwithGoogle(
      LoginWithGoogle event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());
      print("Bắt đầu đăng nhập");
      final googleSignIn = GoogleSignIn(
        // clientId: dotenv.env['CLIENT_ID'],
        serverClientId:
            "152762888438-1hpuulu1khn4iam4lt1m1uo5mtv87pbj.apps.googleusercontent.com",
      );

      final googleUser = await await googleSignIn.signInSilently() ??
          await googleSignIn.signIn();
      if (googleUser == null) {
        print("google use bị Null");
        emit(const AuthenState.unauthenticated());
        return;
      }

      final googleAuth = await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      print("Lấy được Access Token thành công ${accessToken}");
      final idToken = googleAuth.idToken;
      print("Lấy được Id Token thành công ${idToken}");

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

        emit(AuthenState.authenticated(user.id));
      } else {
        emit(const AuthenState.error('Đăng nhập Google thất bại'));
      }
    } on AuthException catch (e) {
      emit(AuthenState.error(_getLocalizedAuthError(e)));
    } catch (e) {
      print('Google login error: $e');
      emit(const AuthenState.error('Có lỗi xảy ra khi đăng nhập với Google'));
    }
  }

  Future<void> _onRegister(
      RegisterEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      // Pre-validation
      if (!_validateRegistrationData(event.email, event.password)) {
        emit(const AuthenState.error('Email hoặc mật khẩu không hợp lệ.'));
        return;
      }

      final client = SupabaseConfig.client;
      print("Tiến hành đăng nhập");
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
      print(response);
      final user = response.user;

      if (user == null) {
        emit(const AuthenState.error(
            'Không thể tạo tài khoản. Vui lòng thử lại.'));
        return;
      }

      // THÊM: Đảm bảo profile được tạo trong public.profiles
      try {
        // Chờ một chút để trigger kích hoạt
        await Future.delayed(const Duration(seconds: 1));

        // Kiểm tra xem profile đã được tạo chưa
        final profile = await client
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .single()
            .timeout(const Duration(seconds: 5));

        print('Profile created successfully: $profile');
      } catch (e) {
        print('Warning: Profile might not be created: $e');
        // Không emit error vì user đã được tạo, chỉ thiếu profile
      }

      if (user.emailConfirmedAt == null) {
        emit(const AuthenState.emailVerificationRequired());
      } else {
        final session = response.session;
        if (session != null) {
          await SessionManager.saveSession(session);
          emit(AuthenState.authenticated(user.id));
        } else {
          emit(const AuthenState.emailVerificationRequired());
        }
      }
    } on AuthException catch (e) {
      String errorMessage = _getLocalizedAuthError(e);
      emit(AuthenState.error(errorMessage));
    } catch (e) {
      print('Registration error: $e');

      // XỬ LÝ LỖI CỤ THỂ
      if (e.toString().contains('unexpected_failure') ||
          e.toString().contains('Database error saving new user')) {
        emit(const AuthenState.error(
            'Lỗi hệ thống. Vui lòng thử lại sau ít phút.'));
      } else {
        emit(const AuthenState.error(
            'Có lỗi xảy ra khi đăng ký. Vui lòng thử lại.'));
      }
    }
  }

  // ĐĂNG NHẬP
  Future<void> _onLogin(LoginEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      // Pre-validation
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
          emit(AuthenState.authenticated(user.id));
        }
      } else {
        emit(const AuthenState.error('Thông tin đăng nhập không chính xác.'));
      }
    } on AuthException catch (e) {
      String errorMessage = _getLocalizedAuthError(e);
      emit(AuthenState.error(errorMessage));
    } catch (e) {
      print('Login error: $e');
      emit(const AuthenState.error(
          'Có lỗi xảy ra khi đăng nhập. Vui lòng thử lại.'));
    }
  }

  // ĐĂNG XUẤT
  Future<void> _onLogout(LogoutEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      await SupabaseConfig.client.auth.signOut();
      await SessionManager.clearSession();

      emit(const AuthenState.unauthenticated());
    } catch (e) {
      print('Logout error: $e');
      // Vẫn emit unauthenticated vì logout cần success
      emit(const AuthenState.unauthenticated());
    }
  }

// KHÔI PHỤC SESSION - FIXED VERSION
  Future<void> _onRestore(
      RestoreSessionEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      final client = SupabaseConfig.client;

      // BƯỚC 1: Thử refresh session trước
      try {
        final currentSession = client.auth.currentSession;
        if (currentSession != null) {
          print("Found existing session, attempting refresh...");
          final refreshResponse = await client.auth.refreshSession();
          if (refreshResponse.session != null) {
            await SessionManager.saveSession(refreshResponse.session!);
            print("Session refreshed successfully");
          }
        }
      } catch (e) {
        print("Session refresh failed: $e");
        // Continue với session cũ nếu refresh fail
      }

      // BƯỚC 2: Kiểm tra session
      final session = await SessionManager.restoreSession();

      if (session != null) {
        print("Session found - Auth Bloc"); // ← Sửa thông báo debug
        final user = client.auth.currentUser;

        if (user != null && !session.isExpired) {
          print("User emailConfirmedAt: ${user.emailConfirmedAt}");

          if (user.emailConfirmedAt != null) {
            print("Email confirmed, authenticating user");
            emit(AuthenState.authenticated(user.id));
          } else {
            print("Email not confirmed, requiring verification");
            emit(const AuthenState.emailVerificationRequired());
          }
        } else {
          // Session expired hoặc invalid
          print("Session expired or user null");
          await SessionManager.clearSession();
          await client.auth.signOut();
          emit(const AuthenState.unauthenticated());
        }
      } else {
        print("No session found");
        emit(const AuthenState.unauthenticated());
      }
    } catch (e) {
      print('Session restore error: $e');
      await SessionManager.clearSession();
      await SupabaseConfig.client.auth.signOut();
      emit(const AuthenState.unauthenticated());
    }
  }

  Future<void> _onCheckEmailVerification(
      CheckEmailVerificationEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      final client = SupabaseConfig.client;

      // Force refresh session để lấy user data mới nhất
      final refreshResponse = await client.auth.refreshSession();

      if (refreshResponse.session != null && refreshResponse.user != null) {
        await SessionManager.saveSession(refreshResponse.session!);

        final user = refreshResponse.user!;
        print("Refreshed user emailConfirmedAt: ${user.emailConfirmedAt}");

        if (user.emailConfirmedAt != null) {
          print("Email verification confirmed!");
          emit(AuthenState.authenticated(user.id));
        } else {
          print("Email still not confirmed");
          emit(const AuthenState.emailVerificationRequired());
        }
      } else {
        emit(const AuthenState.error("Không thể kiểm tra trạng thái xác thực"));
      }
    } catch (e) {
      print('Check email verification error: $e');
      emit(const AuthenState.error("Lỗi kiểm tra xác thự"));
    }
  }

  // XỬ LÝ CALLBACK TỪ DEEP LINK
  Future<void> _onHandleAuthCallback(
      HandleAuthCallbackEvent event, Emitter<AuthenState> emit) async {
    try {
      emit(const AuthenState.loading());

      final client = SupabaseConfig.client;

      // Set session với access token nhận được từ deep link
      final response = await client.auth.setSession(event.accessToken);

      if (response.session != null && response.user != null) {
        await SessionManager.saveSession(response.session!);

        // Kiểm tra email đã được verify chưa
        if (response.user!.emailConfirmedAt != null) {
          emit(AuthenState.authenticated(response.user!.id));
        } else {
          emit(const AuthenState.emailVerificationRequired());
        }
      } else {
        emit(const AuthenState.error(
            'Không thể xác thực email. Vui lòng thử lại.'));
      }
    } catch (e) {
      print('Auth callback error: $e');
      emit(AuthenState.error('Lỗi xác thực email: ${e.toString()}'));
    }
  }

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
      print('Resend verification error: $e');
      emit(const AuthenState.error('Không thể gửi lại email xác thực.'));
    }
  }

  // RESET MẬT KHẨU
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
      print('Reset password error: $e');
      emit(const AuthenState.error('Không thể gửi email reset mật khẩu.'));
    }
  }

  // CẬP NHẬT MẬT KHẨU
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
      print('Update password error: $e');
      emit(const AuthenState.error('Có lỗi xảy ra khi cập nhật mật khẩu.'));
    }
  }

  // VALIDATION HELPERS
  bool _validateRegistrationData(String email, String password) {
    // Validate email format
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    // Validate password strength
    if (password.length < 6) {
      return false;
    }

    return true;
  }

  bool _validateLoginData(String email, String password) {
    if (email.trim().isEmpty || password.isEmpty) {
      return false;
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
    return emailRegex.hasMatch(email);
  }

  // ERROR LOCALIZATION
  String _getLocalizedAuthError(AuthException e) {
    final message = e.message.toLowerCase();

    if (message.contains('email not confirmed') ||
        message.contains('email_not_confirmed')) {
      return 'Email chưa được xác thực. Vui lòng kiểm tra hộp thư và nhấp vào liên kết xác thực.';
    } else if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials')) {
      return 'Email hoặc mật khẩu không chính xác.';
    } else if (message.contains('already registered') ||
        message.contains('already exists')) {
      return 'Email này đã được đăng ký. Vui lòng sử dụng email khác hoặc đăng nhập.';
    } else if (message.contains('invalid email')) {
      return 'Email không hợp lệ.';
    } else if (message.contains('password')) {
      if (message.contains('too short')) {
        return 'Mật khẩu quá ngắn. Vui lòng sử dụng ít nhất 6 ký tự.';
      }
      return 'Mật khẩu không hợp lệ.';
    } else if (message.contains('too many requests') ||
        message.contains('rate limit')) {
      return 'Quá nhiều yêu cầu. Vui lòng đợi một lúc rồi thử lại.';
    } else if (message.contains('network') || message.contains('connection')) {
      return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet và thử lại.';
    } else if (message.contains('user not found')) {
      return 'Không tìm thấy tài khoản với email này.';
    } else if (message.contains('token')) {
      return 'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.';
    } else if (message.contains('google') || message.contains('oauth')) {
      if (message.contains('popup') || message.contains('cancelled')) {
        return 'Đăng nhập Google đã bị hủy';
      } else if (message.contains('invalid_credentials') ||
          message.contains('invalid_token')) {
        return 'Token Google không hợp lệ. Vui lòng thử lại.';
      } else if (message.contains('configuration')) {
        return 'Cấu hình Google OAuth chưa đúng. Liên hệ quản trị viên.';
      }
      return 'Lỗi đăng nhập Google. Vui lòng thử lại.';
    } else if (message.contains('google') || message.contains('oauth')) {
      if (message.contains('popup') ||
          message.contains('cancelled') ||
          message.contains('user_cancelled')) {
        return 'Đăng nhập Google đã bị hủy';
      } else if (message.contains('invalid_credentials') ||
          message.contains('invalid_token')) {
        return 'Token Google không hợp lệ. Vui lòng thử lại.';
      } else if (message.contains('configuration')) {
        return 'Cấu hình Google OAuth chưa đúng. Liên hệ quản trị viên.';
      } else if (message.contains('network') ||
          message.contains('connection')) {
        return 'Lỗi kết nối mạng trong quá trình đăng nhập Google';
      } else if (message.contains('timeout')) {
        return 'Đăng nhập Google quá thời gian chờ';
      }
      return 'Lỗi đăng nhập Google. Vui lòng thử lại.';
    }

    return e.message.isNotEmpty
        ? e.message
        : 'Có lỗi xảy ra. Vui lòng thử lại.';
  }

  // UTILITY METHODS
  bool get isAuthenticated {
    return state.status == AuthStatus.authenticated;
  }

  bool get isLoading {
    return state.status == AuthStatus.loading;
  }

  String? get currentUserId {
    return state.userId;
  }

  // Kiểm tra và refresh token nếu cần
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
      print('Token refresh error: $e');
      add(LogoutEvent()); // Logout nếu không thể refresh
    }
  }

  // Clean up khi dispose
  @override
  Future<void> close() async {
    // Có thể thêm cleanup logic ở đây nếu cần
    return super.close();
  }
}
