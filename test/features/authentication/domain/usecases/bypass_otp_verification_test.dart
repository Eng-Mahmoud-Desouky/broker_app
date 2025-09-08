import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:broker_app/core/error/failures.dart';
import 'package:broker_app/features/authentication/domain/entities/auth_session.dart';
import 'package:broker_app/features/authentication/domain/entities/user.dart';
import 'package:broker_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:broker_app/features/authentication/domain/usecases/bypass_otp_verification.dart';

import 'bypass_otp_verification_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late BypassOtpVerification usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = BypassOtpVerification(mockAuthRepository);
  });

  const testPhoneNumber = '+9647700000000';
  final testUser = User(
    id: 'test_id',
    phoneNumber: testPhoneNumber,
    createdAt: DateTime.now(),
    isVerified: true,
  );
  final testSession = AuthSession(
    accessToken: 'test_token',
    refreshToken: 'test_refresh',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
    user: testUser,
  );

  group('BypassOtpVerification', () {
    test('should bypass OTP verification and return session when phone number is valid', () async {
      // arrange
      when(mockAuthRepository.bypassOtpVerification(any))
          .thenAnswer((_) async => Right(testSession));

      // act
      final result = await usecase(const BypassOtpParams(phoneNumber: testPhoneNumber));

      // assert
      expect(result, Right(testSession));
      verify(mockAuthRepository.bypassOtpVerification(testPhoneNumber));
      verifyNoMoreInteractions(mockAuthRepository);
    });

    test('should return InvalidPhoneNumberFailure when phone number is invalid', () async {
      // arrange
      const invalidPhoneNumber = '123456';

      // act
      final result = await usecase(const BypassOtpParams(phoneNumber: invalidPhoneNumber));

      // assert
      expect(result, const Left(InvalidPhoneNumberFailure(
        message: 'رقم الهاتف غير صحيح. يجب أن يكون رقم عراقي صحيح.',
      )));
      verifyZeroInteractions(mockAuthRepository);
    });

    test('should return failure when repository returns failure', () async {
      // arrange
      when(mockAuthRepository.bypassOtpVerification(any))
          .thenAnswer((_) async => const Left(ServerFailure(message: 'Server error')));

      // act
      final result = await usecase(const BypassOtpParams(phoneNumber: testPhoneNumber));

      // assert
      expect(result, const Left(ServerFailure(message: 'Server error')));
      verify(mockAuthRepository.bypassOtpVerification(testPhoneNumber));
      verifyNoMoreInteractions(mockAuthRepository);
    });
  });
}
