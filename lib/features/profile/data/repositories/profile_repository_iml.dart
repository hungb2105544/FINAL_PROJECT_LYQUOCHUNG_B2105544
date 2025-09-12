import 'dart:io';
import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/profile/data/model/user_profile.dart';
import 'package:ecommerce_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:ecommerce_app/features/profile/data/local/hive_profile_setup.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseProfileRepository implements ProfileRepository {
  final SupabaseClient _client = SupabaseConfig.client;

  @override
  Future<UserProfile?> getUserProfile(String userId) async {
    try {
      // Try to get from remote first
      final response = await _client
          .from("user_profiles")
          .select('*')
          .eq('id', userId)
          .maybeSingle();

      if (response != null) {
        final profile = UserProfile.fromJson(response as Map<String, dynamic>);
        // Cache the profile locally
        await HiveProfileSetup.cacheUserProfile(userId, profile);
        return profile;
      }

      // If remote fails, try to get from cache
      return HiveProfileSetup.getCachedUserProfile(userId);
    } catch (e) {
      // If network error, return cached data
      print('Error fetching profile from remote: $e');
      return HiveProfileSetup.getCachedUserProfile(userId);
    }
  }

  @override
  Future<UserProfile> updateUserProfile(
      UserProfile profile, File? avatarFile) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    try {
      String? avatarUrl;

      if (avatarFile != null) {
        avatarUrl = await uploadAvatar(user.id, avatarFile);
      }

      final updateData = <String, dynamic>{
        'full_name': profile.fullName,
        'phone_number': profile.phoneNumber,
        'gender': profile.gender,
        'date_of_birth': profile.dateOfBirth?.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (avatarUrl != null) {
        updateData['avatar_url'] = avatarUrl;
      }

      await _client.from('user_profiles').update(updateData).eq('id', user.id);

      final updatedResponse = await _client
          .from("user_profiles")
          .select('*')
          .eq('id', user.id)
          .single();

      final updatedProfile = UserProfile.fromJson(updatedResponse);

      // Cache the updated profile
      await HiveProfileSetup.cacheUserProfile(user.id, updatedProfile);

      return updatedProfile;
    } catch (e) {
      // If update fails, still cache the attempted changes locally
      final updatedProfile = profile.copyWith(
        updatedAt: DateTime.now(),
      );
      await HiveProfileSetup.cacheUserProfile(user.id, updatedProfile);
      rethrow; // Re-throw to let BLoC handle the error
    }
  }

  @override
  Future<String> uploadAvatar(String userId, File avatarFile) async {
    final filePath =
        'user_$userId/avatar_${DateTime.now().millisecondsSinceEpoch}.png';

    await _client.storage.from('user').upload(
          filePath,
          avatarFile,
          fileOptions: const FileOptions(upsert: true),
        );

    return _client.storage.from('user').getPublicUrl(filePath);
  }
}
