import 'dart:io';

import 'package:ecommerce_app/features/profile/data/model/user_profile.dart';

abstract class ProfileRepository {
  Future<UserProfile?> getUserProfile(String userId);
  Future<UserProfile> updateUserProfile(UserProfile profile, File? avatarFile);
  Future<String> uploadAvatar(String userId, File avatarFile);
}
