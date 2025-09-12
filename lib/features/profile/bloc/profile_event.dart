import 'dart:io';
import 'package:ecommerce_app/features/profile/data/model/user_profile.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String? userId;

  LoadProfile({this.userId});

  @override
  List<Object?> get props => [userId];
}

class UpdateProfile extends ProfileEvent {
  final UserProfile updatedProfile;
  final File?
      imageAvatar; // Made optional since user might not always update avatar

  UpdateProfile({
    required this.updatedProfile,
    this.imageAvatar,
  });

  @override
  List<Object?> get props => [updatedProfile, imageAvatar];
}

class ResetProfileState extends ProfileEvent {}
