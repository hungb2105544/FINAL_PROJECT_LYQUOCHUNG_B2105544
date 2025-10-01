import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SupabaseConfig {
  static final String _supabaseUrl = dotenv.env['SUPABASE_URL'] ?? '';
  static final String _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? '';

  static Future<void> initialize() async {
    await Hive.initFlutter();

    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: true,
        localStorage: HiveLocalStorage(),
      ),
    );
  }

  static SupabaseClient get client => Supabase.instance.client;
}

class HiveLocalStorage extends LocalStorage {
  late Box _box;

  HiveLocalStorage() {
    _initBox();
  }

  Future<void> _initBox() async {
    _box = await Hive.openBox('supabase_storage');
  }

  @override
  Future<void> initialize() async {
    await _initBox();
  }

  @override
  Future<String?> accessToken() async {
    return _box.get('supabase.auth.token');
  }

  @override
  Future<bool> hasAccessToken() async {
    return _box.containsKey('supabase.auth.token');
  }

  @override
  Future<void> persistSession(String persistSessionString) async {
    await _box.put('supabase.auth.token', persistSessionString);
  }

  @override
  Future<void> removePersistedSession() async {
    await _box.delete('supabase.auth.token');
  }
}
