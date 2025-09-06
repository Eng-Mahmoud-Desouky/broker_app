import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class VerifyOtp implements UseCase<AuthSession, VerifyOtpParams> {
  final AuthRepository repository;

  VerifyOtp(this.repository);

  @override
  Future<Either<Failure, AuthSession>> call(VerifyOtpParams params) async {
    // Validate phone number
    if (!Validators.isValidIraqiPhoneNumber(params.phoneNumber)) {
      return const Left(InvalidPhoneNumberFailure(
        message: 'رقم الهاتف غير صحيح. يجب أن يكون رقم عراقي صحيح.',
      ));
    }

    // Validate OTP
    if (!Validators.isValidOtp(params.otp)) {
      return const Left(InvalidOtpFailure(
        message: 'رمز التحقق غير صحيح. يجب أن يكون 6 أرقام.',
      ));
    }

    // Format phone number to international format
    final formattedPhoneNumber = Validators.getInternationalFormat(params.phoneNumber);

    return await repository.verifyOtp(formattedPhoneNumber, params.otp);
  }
}

class VerifyOtpParams extends Equatable {
  final String phoneNumber;
  final String otp;

  const VerifyOtpParams({
    required this.phoneNumber,
    required this.otp,
  });

  @override
  List<Object> get props => [phoneNumber, otp];
}
