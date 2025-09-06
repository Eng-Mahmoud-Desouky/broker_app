part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

class AuthOtpSent extends AuthState {
  final String phoneNumber;

  const AuthOtpSent({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}

class AuthAuthenticated extends AuthState {
  final AuthSession session;

  const AuthAuthenticated({required this.session});

  @override
  List<Object> get props => [session];
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object> get props => [message];
}
