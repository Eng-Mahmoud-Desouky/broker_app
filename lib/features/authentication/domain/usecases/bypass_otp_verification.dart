import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

/// Use case for bypassing OTP verification in development/testing mode
/// This creates a mock session without actual OTP verification
class BypassOtpVerification implements UseCase<AuthSession, BypassOtpParams> {
  final AuthRepository repository;

  BypassOtpVerification(this.repository);

  @override
  Future<Either<Failure, AuthSession>> call(BypassOtpParams params) async {
    // Extract just the number part if it's in international format
    String phoneToValidate = params.phoneNumber;
    if (phoneToValidate.startsWith('+964')) {
      phoneToValidate = phoneToValidate.substring(4); // Remove +964
    }

    // Validate phone number
    if (!Validators.isValidIraqiPhoneNumber(phoneToValidate)) {
      return const Left(
        InvalidPhoneNumberFailure(
          message: 'رقم الهاتف غير صحيح. يجب أن يكون رقم عراقي صحيح.',
        ),
      );
    }

    // Use the original phone number (already in international format from IntlPhoneField)
    final formattedPhoneNumber = params.phoneNumber;

    // Call repository method to create a bypass session
    return await repository.bypassOtpVerification(formattedPhoneNumber);
  }
}

class BypassOtpParams extends Equatable {
  final String phoneNumber;

  const BypassOtpParams({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}
