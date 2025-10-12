import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

class NetworkFailure extends Failure {
  const NetworkFailure({required super.message});
}

class ValidationFailure extends Failure {
  const ValidationFailure({required super.message});
}

// Authentication specific failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure({required super.message});
}

class InvalidPhoneNumberFailure extends Failure {
  const InvalidPhoneNumberFailure({required super.message});
}

class InvalidOtpFailure extends Failure {
  const InvalidOtpFailure({required super.message});
}

class OtpExpiredFailure extends Failure {
  const OtpExpiredFailure({required super.message});
}

// Wallet specific failures
class WalletFailure extends Failure {
  const WalletFailure({required super.message});
}

class InsufficientBalanceFailure extends Failure {
  const InsufficientBalanceFailure({required super.message});
}

class PaymentFailure extends Failure {
  const PaymentFailure({required super.message});
}

class InvalidAmountFailure extends Failure {
  const InvalidAmountFailure({required super.message});
}
