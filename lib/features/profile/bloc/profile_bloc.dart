import 'dart:io';

import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
import 'package:ecommerce_app/features/profile/bloc/profile_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/features/profile/data/model/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(ProfileInitial()) {
    on<LoadProfile>(_onLoadingProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadingProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final userId = event.userId;
      final client = SupabaseConfig.client;

      final response = await client
          .from("user_profiles")
          .select('*')
          .eq('id', userId.toString())
          .maybeSingle();

      if (response == null) {
        emit(ProfileError(message: 'Profile not found'));
        return;
      }

      final result = UserProfile.fromJson(response as Map<String, dynamic>);
      emit(ProfileLoaded(userProfile: result));
    } catch (error) {
      emit(ProfileError(message: 'Failed to load profile: $error'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    // Kiểm tra input
    if (event.updatedProfile == null) {
      emit(ProfileError(message: 'Updated profile cannot be null'));
      return;
    }

    emit(ProfileUpdating());

    try {
      final client = SupabaseConfig.client;
      final user = client.auth.currentUser;
      final session = client.auth.currentSession;

      if (user == null || session == null) {
        emit(ProfileError(message: 'User not authenticated'));
        return;
      }

      final id = user.id;

      print("🔐 User ID: $id");
      print("🔐 User role: ${user.role}");
      print("🔐 User email: ${user.email}");
      print("🔐 Access token exists: ${session.accessToken.isNotEmpty}");
      print(
          "🔐 Token expires at: ${DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)}");
      print("🔐 Current time: ${DateTime.now()}");
      String? newUrl;

      if (event.imageAvatar != null) {
        final fileAvatar = event.imageAvatar!;
        if (!await fileAvatar.exists()) {
          emit(ProfileError(message: "File ảnh không tồn tại"));
          return; //
        }

        final fileSize = await fileAvatar.length();
        if (fileSize > 5 * 1024 * 1024) {
          emit(ProfileError(message: "File ảnh quá lớn (max 5MB)"));
          return;
        }
        if (event.updatedProfile.avatarUrl != null &&
            event.updatedProfile.avatarUrl!.isNotEmpty) {
          try {
            // avatarUrl là public URL → cần cắt lấy filePath
            final oldUrl = event.updatedProfile.avatarUrl!;
            final oldPath =
                oldUrl.split('/storage/v1/object/public/user/').last;

            print("🗑️ Deleting old avatar: $oldPath");

            await client.storage.from('user').remove([oldPath]);

            print("✅ Old avatar deleted");
          } catch (deleteError) {
            print("⚠️ Warning: Could not delete old avatar: $deleteError");
          }
        }
        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final filePath = 'avatars/${user.id}_$timestamp.png';

        print("📤 Uploading file to: $filePath");
        print("📁 File size: ${fileSize / 1024} KB");

        try {
          final uploadResult =
              await client.storage.from('user').upload(filePath, fileAvatar,
                  fileOptions: const FileOptions(
                    upsert: true,
                    contentType: 'image/png',
                  ));

          print("✅ Upload successful: $uploadResult");

          newUrl = client.storage.from('user').getPublicUrl(filePath);
          print("🔗 New URL: $newUrl");
        } catch (uploadError) {
          print("❌ Upload error: $uploadError");

          if (uploadError is StorageException) {
            print("Storage error code: ${uploadError.statusCode}");
            print("Storage error message: ${uploadError.message}");
            emit(ProfileError(message: 'Lỗi upload: ${uploadError.message}'));
          } else {
            emit(ProfileError(message: 'Lỗi upload ảnh: $uploadError'));
          }
          return;
        }
      }

      final updateData = <String, dynamic>{
        'full_name': event.updatedProfile.fullName,
        'phone_number': event.updatedProfile.phoneNumber,
        'gender': event.updatedProfile.gender,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (event.updatedProfile.dateOfBirth != null) {
        updateData['date_of_birth'] =
            event.updatedProfile.dateOfBirth!.toIso8601String();
      }

      if (newUrl != null) {
        updateData['avatar_url'] = newUrl;
      }

      print("📝 Updating profile with data: $updateData");

      await client.from('user_profiles').update(updateData).eq('id', id);

      print("✅ Profile updated successfully");

      final updatedProfileWithNewUrl = UserProfile(
        id: event.updatedProfile.id,
        fullName: event.updatedProfile.fullName,
        phoneNumber: event.updatedProfile.phoneNumber,
        gender: event.updatedProfile.gender,
        dateOfBirth: event.updatedProfile.dateOfBirth,
        avatarUrl: newUrl ?? event.updatedProfile.avatarUrl,
      );

      await Future.delayed(const Duration(seconds: 1));
      emit(ProfileLoaded(userProfile: updatedProfileWithNewUrl));
      emit(ProfileUpdateSuccess(message: 'Profile updated successfully'));
    } catch (error) {
      print("❌ Update profile error: $error");

      if (error is PostgrestException) {
        print("Postgrest error: ${error.message}");
        print("Error details: ${error.details}");
        print("Error code: ${error.code}");
      }

      emit(ProfileError(message: 'Failed to update profile: $error'));
    }
  }
}
