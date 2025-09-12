import 'package:ecommerce_app/features/profile/data/model/user_profile.dart';
import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileUpdating extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserProfile userProfile;

  ProfileLoaded({required this.userProfile});

  @override
  List<Object?> get props => [userProfile];
}

class ProfileUpdateSuccess extends ProfileState {
  final String message;

  ProfileUpdateSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class ProfileError extends ProfileState {
  final String message;

  ProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
