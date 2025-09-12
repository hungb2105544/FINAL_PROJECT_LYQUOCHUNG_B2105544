import 'package:equatable/equatable.dart';

class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoginEvent extends AuthEvent {
  final String email;
  final String password;

  LoginEvent({required this.email, required this.password});
}

class LogoutEvent extends AuthEvent {}

class RestoreSessionEvent extends AuthEvent {}

class RegisterEvent extends AuthEvent {
  final String email;
  final String password;

  RegisterEvent({required this.email, required this.password});
}

class HandleAuthCallbackEvent extends AuthEvent {
  final String accessToken;
  final String? refreshToken;

  HandleAuthCallbackEvent({
    required this.accessToken,
    this.refreshToken,
  });

  @override
  List<Object?> get props => [accessToken, refreshToken];
}

class ResendVerificationEvent extends AuthEvent {
  final String email;

  ResendVerificationEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class ResetPasswordEvent extends AuthEvent {
  final String email;

  ResetPasswordEvent({required this.email});

  @override
  List<Object?> get props => [email];
}

class UpdatePasswordEvent extends AuthEvent {
  final String newPassword;

  UpdatePasswordEvent({required this.newPassword});

  @override
  List<Object?> get props => [newPassword];
}

class CheckEmailVerificationEvent extends AuthEvent {
  CheckEmailVerificationEvent();

  @override
  List<Object?> get props => [];
}

class LoginWithGoogle extends AuthEvent {
  LoginWithGoogle();

  @override
  List<Object?> get props => [];
}
