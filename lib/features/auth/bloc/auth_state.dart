// lib/features/auth/bloc/auth_state.dart
import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  emailVerificationRequired,
  passwordResetSent,
  passwordUpdated,
  error
}

class AuthenState extends Equatable {
  final AuthStatus status;
  final String? userId;
  final String? errorMessage;

  const AuthenState._({
    this.status = AuthStatus.initial,
    this.userId,
    this.errorMessage,
  });

  // CONSTRUCTORS
  const AuthenState.initial() : this._();

  const AuthenState.loading() : this._(status: AuthStatus.loading);

  const AuthenState.authenticated(String userId)
      : this._(status: AuthStatus.authenticated, userId: userId);

  const AuthenState.unauthenticated()
      : this._(status: AuthStatus.unauthenticated);

  const AuthenState.emailVerificationRequired()
      : this._(status: AuthStatus.emailVerificationRequired);

  const AuthenState.passwordResetSent()
      : this._(status: AuthStatus.passwordResetSent);

  const AuthenState.passwordUpdated()
      : this._(status: AuthStatus.passwordUpdated);

  const AuthenState.error(String message)
      : this._(status: AuthStatus.error, errorMessage: message);

  // HELPER METHODS
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get isLoading => status == AuthStatus.loading;
  bool get needsEmailVerification =>
      status == AuthStatus.emailVerificationRequired;
  bool get hasError => status == AuthStatus.error;

  @override
  List<Object?> get props => [status, userId, errorMessage];

  @override
  String toString() {
    return 'AuthenState { status: $status, userId: $userId, error: $errorMessage }';
  }

  // COPY WITH METHOD
  AuthenState copyWith({
    AuthStatus? status,
    String? userId,
    String? errorMessage,
  }) {
    return AuthenState._(
      status: status ?? this.status,
      userId: userId ?? this.userId,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
