part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthSendOtpRequested extends AuthEvent {
  final String phoneNumber;

  const AuthSendOtpRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthVerifyOtpRequested extends AuthEvent {
  final String phoneNumber;
  final String otp;

  const AuthVerifyOtpRequested({required this.phoneNumber, required this.otp});

  @override
  List<Object?> get props => [phoneNumber, otp];
}

class AuthSignOutRequested extends AuthEvent {}

/// Event to bypass OTP verification for development/testing purposes
class AuthBypassOtpRequested extends AuthEvent {
  final String phoneNumber;

  const AuthBypassOtpRequested({required this.phoneNumber});

  @override
  List<Object?> get props => [phoneNumber];
}

class AuthUpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? email;
  final String? profilePicture;
  final String? governorate;
  final String? district;

  const AuthUpdateProfileRequested({
    this.name,
    this.email,
    this.profilePicture,
    this.governorate,
    this.district,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    profilePicture,
    governorate,
    district,
  ];
}
