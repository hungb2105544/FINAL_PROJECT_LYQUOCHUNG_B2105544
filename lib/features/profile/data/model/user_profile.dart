import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 13)
class UserProfile {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String? phoneNumber;
  @HiveField(2)
  final String? gender;
  @HiveField(3)
  final DateTime? dateOfBirth;
  @HiveField(4)
  final String? fullName;
  @HiveField(5)
  final String? avatarUrl;
  @HiveField(6)
  final DateTime? createdAt;
  @HiveField(7)
  final DateTime? updatedAt;
  @HiveField(8)
  final String? registrationSource;
  @HiveField(9)
  final DateTime? registrationTimestamp;
  @HiveField(10)
  final String? appName;

  UserProfile({
    required this.id,
    this.phoneNumber,
    this.gender,
    this.dateOfBirth,
    this.fullName,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.registrationSource,
    this.registrationTimestamp,
    this.appName,
  });

  /// Tạo object từ JSON (map) lấy từ Supabase
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      phoneNumber: json['phone_number'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'])
          : null,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
      registrationSource: json['registration_source'] as String?,
      registrationTimestamp: json['registration_timestamp'] != null
          ? DateTime.parse(json['registration_timestamp'])
          : null,
      appName: json['app_name'] as String?,
    );
  }

  /// Chuyển object thành JSON để insert/update lên Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone_number': phoneNumber,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'registration_source': registrationSource,
      'registration_timestamp': registrationTimestamp?.toIso8601String(),
      'app_name': appName,
    };
  }

  /// CopyWith để dễ update field cụ thể
  UserProfile copyWith({
    String? phoneNumber,
    String? gender,
    DateTime? dateOfBirth,
    String? fullName,
    String? avatarUrl,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      registrationSource: registrationSource,
      registrationTimestamp: registrationTimestamp,
      appName: appName,
    );
  }
}
