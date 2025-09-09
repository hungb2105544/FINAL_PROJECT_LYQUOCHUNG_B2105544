import 'dart:convert';
import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:hive/hive.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SessionManager {
  static const _boxName = 'sessionBox';
  static const _key = 'current_session';
  static Box<String>? _box;

  /// Khởi tạo box (gọi 1 lần khi app start)
  static Future<void> initialize() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  /// Đảm bảo box đã được khởi tạo
  static Future<Box<String>> _getBox() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox<String>(_boxName);
    }
    return _box!;
  }

  /// Lưu session (dưới dạng JSON)
  static Future<void> saveSession(Session session) async {
    try {
      final box = await _getBox();
      // Chuyển session thành JSON string
      final sessionJson = session.toJson();
      await box.put(_key, jsonEncode(sessionJson));
      print('Session saved successfully');
    } catch (e) {
      print('Error saving session: $e');
      rethrow;
    }
  }

  /// Lấy session string đã lưu
  static Future<String?> getSession() async {
    try {
      final box = await _getBox();
      return box.get(_key);
    } catch (e) {
      print('Error getting session: $e');
      return null;
    }
  }

  /// Xoá session
  static Future<void> clearSession() async {
    try {
      final box = await _getBox();
      await box.delete(_key);
      print('Session cleared successfully');
    } catch (e) {
      print('Error clearing session: $e');
      rethrow;
    }
  }

  /// Kiểm tra có session hay không
  static Future<bool> hasSession() async {
    try {
      final box = await _getBox();
      return box.containsKey(_key);
    } catch (e) {
      print('Error checking session: $e');
      return false;
    }
  }

  /// Khôi phục session vào Supabase
  static Future<Session?> restoreSession() async {
    try {
      final supabase = SupabaseConfig.client;
      final saved = await getSession();

      if (saved != null && saved.isNotEmpty) {
        print('Attempting to restore session...');

        // Parse JSON string thành Map
        final sessionData = jsonDecode(saved) as Map<String, dynamic>;

        // Tạo lại Session từ JSON
        final session = Session.fromJson(sessionData);

        // Sử dụng recoverSession với refresh token
        if (session?.refreshToken != null) {
          final response =
              await supabase.auth.refreshSession(session?.refreshToken!);
          final newSession = response.session;

          if (newSession != null) {
            // Lưu session mới
            await saveSession(newSession);
            print('Session restored successfully');
            return newSession;
          }
        }

        print('Failed to restore session');
        await clearSession();
      } else {
        print('No saved session found');
      }
    } catch (e) {
      print('Error restoring session: $e');
      // Xóa session cũ nếu có lỗi
      await clearSession();
    }
    return null;
  }

  /// Lấy user hiện tại từ session
  static Future<User?> getCurrentUser() async {
    try {
      final supabase = SupabaseConfig.client;
      return supabase.auth.currentUser;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  /// Kiểm tra user có đang logged in không
  static Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  /// Đăng xuất và xóa session
  static Future<void> signOut() async {
    try {
      final supabase = SupabaseConfig.client;
      await supabase.auth.signOut();
      await clearSession();
      print('Signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      // Vẫn xóa session local dù có lỗi
      await clearSession();
      rethrow;
    }
  }

  /// Đóng box khi không sử dụng
  static Future<void> dispose() async {
    if (_box != null && _box!.isOpen) {
      await _box!.close();
      _box = null;
    }
  }
}
