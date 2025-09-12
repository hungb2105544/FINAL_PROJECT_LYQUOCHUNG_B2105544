import 'package:hive_flutter/hive_flutter.dart';
import 'package:ecommerce_app/features/profile/data/model/user_profile.dart';

class HiveProfileSetup {
  static const String profileBoxName = 'profile_box';
  static const String userProfileKey = 'user_profile_';

  static Future<void> initHive() async {
    await Hive.initFlutter();

    // Register UserProfile adapter if not already registered
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(UserProfileAdapter());
    }

    // Open the profile box
    await Hive.openBox<UserProfile>(profileBoxName);
  }

  static Box<UserProfile> get profileBox =>
      Hive.box<UserProfile>(profileBoxName);

  static Future<void> cacheUserProfile(
      String userId, UserProfile profile) async {
    final box = profileBox;
    await box.put('$userProfileKey$userId', profile);
  }

  static UserProfile? getCachedUserProfile(String userId) {
    final box = profileBox;
    return box.get('$userProfileKey$userId');
  }

  static Future<void> clearUserProfile(String userId) async {
    final box = profileBox;
    await box.delete('$userProfileKey$userId');
  }

  static Future<void> clearAllProfiles() async {
    final box = profileBox;
    await box.clear();
  }
}
