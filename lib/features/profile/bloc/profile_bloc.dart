// import 'package:ecommerce_app/core/data/datasources/supabase_client.dart';
// import 'package:ecommerce_app/features/profile/bloc/profile_event.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:ecommerce_app/features/profile/data/model/user_profile.dart';
// import 'package:supabase_flutter/supabase_flutter.dart';

// import 'profile_state.dart';

// class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
//   ProfileBloc() : super(ProfileInitial()) {
//     on<LoadProfile>(_onLoadingProfile);
//     on<UpdateProfile>(_onUpdateProfile);
//   }

//   Future<void> _onLoadingProfile(
//     LoadProfile event,
//     Emitter<ProfileState> emit,
//   ) async {
//     emit(ProfileLoading());

//     final userId = event.userId;

//     final client = SupabaseConfig.client;

//     final response = await client
//         .from("user_profiles")
//         .select('*')
//         .eq('id', userId.toString())
//         .maybeSingle();

//     final result = UserProfile.fromJson(response as Map<String, dynamic>);
//     emit(ProfileLoaded(userProfile: result));
//     try {
//       await Future.delayed(const Duration(seconds: 2));
//     } catch (error) {
//       emit(ProfileError(message: 'Failed to load profile: $error'));
//     }
//   }

//   Future<void> _onUpdateProfile(
//     UpdateProfile event,
//     Emitter<ProfileState> emit,
//   ) async {
//     if (event.updatedProfile == null) {
//       emit(ProfileError(message: 'Updated profile cannot be null'));
//       return;
//     }

//     emit(ProfileUpdating());

//     try {
//       final client = SupabaseConfig.client;
//       final fileAvatr = event.imageAvatar;
//       final user = client.auth.currentUser;
//       final id = user!.id;
//       if (fileAvatr == null) {
//         emit(ProfileError(message: "Ảnh không tồn tại"));
//       }

//       final filePath = 'user_${user.id}/avatar.png';
//       final imageResponse = await client.storage.from('user').upload(
//           filePath, fileAvatr,
//           fileOptions: const FileOptions(upsert: true));
//       final newUrl =
//           client.storage.from('user').getPublicUrl('user_$id/avatar.png');

//       final response = client.from('user_profiles').update({
//         'full_name': event.updatedProfile.fullName,
//         'phone_number': event.updatedProfile.phoneNumber,
//         'gender': event.updatedProfile.gender,
//         'date_of_birth': event.updatedProfile.dateOfBirth,
//         'avatar_url': newUrl,
//         'updated_at': DateTime.now()
//       }).eq('id', id);

//       await Future.delayed(const Duration(seconds: 1));
//       emit(ProfileLoaded(userProfile: event.updatedProfile));
//       emit(ProfileUpdateSuccess(message: 'Profile updated successfully'));
//     } catch (error) {
//       emit(ProfileError(message: 'Failed to update profile: $error'));
//     }
//   }
// }
import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ecommerce_app/features/profile/data/model/user_profile.dart';
import 'package:ecommerce_app/features/profile/domain/repositories/profile_repository.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileBloc({required ProfileRepository profileRepository})
      : _profileRepository = profileRepository,
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<ResetProfileState>(_onResetProfileState);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());

    try {
      final userId = event.userId;
      if (userId == null || userId.isEmpty) {
        emit(ProfileError(message: 'User ID is required'));
        return;
      }

      final userProfile = await _profileRepository.getUserProfile(userId);

      if (userProfile != null) {
        emit(ProfileLoaded(userProfile: userProfile));
      } else {
        emit(ProfileError(message: 'Profile not found'));
      }
    } catch (error) {
      emit(ProfileError(message: 'Failed to load profile: $error'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileUpdating());

    try {
      final updatedProfile = await _profileRepository.updateUserProfile(
        event.updatedProfile,
        event.imageAvatar,
      );

      emit(ProfileLoaded(userProfile: updatedProfile));
      emit(ProfileUpdateSuccess(message: 'Profile updated successfully'));
    } catch (error) {
      emit(ProfileError(message: 'Failed to update profile: $error'));
    }
  }

  void _onResetProfileState(
    ResetProfileState event,
    Emitter<ProfileState> emit,
  ) {
    emit(ProfileInitial());
  }
}
