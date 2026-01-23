import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

class SendOtp implements UseCase<void, SendOtpParams> {
  final AuthRepository repository;

  SendOtp(this.repository);

  @override
  Future<Either<Failure, void>> call(SendOtpParams params) async {
    print('\n🔍 ===== SendOtp Use Case =====');
    print('🔍 Raw phone: ${params.phoneNumber}');

    // Validate phone number
    final isValid = Validators.isValidIraqiPhoneNumber(params.phoneNumber);
    print('🔍 Is valid Iraqi number: $isValid');

    if (!isValid) {
      print('❌ Validation failed - returning error');
      print('================================\n');
      return const Left(
        InvalidPhoneNumberFailure(
          message: 'رقم الهاتف غير صحيح. يجب أن يكون رقم عراقي صحيح.',
        ),
      );
    }

    // Format phone number to international format
    final formattedPhoneNumber = Validators.getInternationalFormat(
      params.phoneNumber,
    );
    print('✅ Formatted phone: $formattedPhoneNumber');
    print('🚀 Sending to Supabase...');
    print('================================\n');

    return await repository.sendOtp(formattedPhoneNumber);
  }
}

class SendOtpParams extends Equatable {
  final String phoneNumber;

  const SendOtpParams({required this.phoneNumber});

  @override
  List<Object> get props => [phoneNumber];
}
