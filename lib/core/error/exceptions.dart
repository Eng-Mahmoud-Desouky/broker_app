class ServerException implements Exception {
  final String message;

  const ServerException({required this.message});
}

class CacheException implements Exception {
  final String message;

  const CacheException({required this.message});
}

class NetworkException implements Exception {
  final String message;

  const NetworkException({required this.message});
}

class ValidationException implements Exception {
  final String message;

  const ValidationException({required this.message});
}

class AuthenticationException implements Exception {
  final String message;

  const AuthenticationException({required this.message});
}

class InvalidPhoneNumberException implements Exception {
  final String message;

  const InvalidPhoneNumberException({required this.message});
}

class InvalidOtpException implements Exception {
  final String message;

  const InvalidOtpException({required this.message});
}

class OtpExpiredException implements Exception {
  final String message;

  const OtpExpiredException({required this.message});
}

class WalletException implements Exception {
  final String message;

  const WalletException({required this.message});
}

class InsufficientBalanceException implements Exception {
  final String message;

  const InsufficientBalanceException({required this.message});
}

class PaymentException implements Exception {
  final String message;

  const PaymentException({required this.message});
}

class InvalidAmountException implements Exception {
  final String message;

  const InvalidAmountException({required this.message});
}
