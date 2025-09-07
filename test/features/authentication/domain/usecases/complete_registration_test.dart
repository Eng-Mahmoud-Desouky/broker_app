import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:broker_app/core/error/failures.dart';
import 'package:broker_app/features/authentication/domain/repositories/auth_repository.dart';
import 'package:broker_app/features/authentication/domain/usecases/complete_registration.dart';

import 'complete_registration_test.mocks.dart';

@GenerateMocks([AuthRepository])
void main() {
  late CompleteRegistration usecase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    usecase = CompleteRegistration(mockAuthRepository);
  });

  const tFullName = 'أحمد محمد علي';
  const tGovernorate = 'بغداد';
  const tDistrict = 'الرصافة';
  const tParams = CompleteRegistrationParams(
    fullName: tFullName,
    governorate: tGovernorate,
    district: tDistrict,
  );

  group('CompleteRegistration', () {
    test('should call repository updateProfile with correct parameters', () async {
      // arrange
      when(mockAuthRepository.updateProfile(
        name: anyNamed('name'),
        governorate: anyNamed('governorate'),
        district: anyNamed('district'),
      )).thenAnswer((_) async => const Right(null));

      // act
      await usecase(tParams);

      // assert
      verify(mockAuthRepository.updateProfile(
        name: tFullName,
        governorate: tGovernorate,
        district: tDistrict,
      ));
    });

    test('should return Right(null) when profile update is successful', () async {
      // arrange
      when(mockAuthRepository.updateProfile(
        name: anyNamed('name'),
        governorate: anyNamed('governorate'),
        district: anyNamed('district'),
      )).thenAnswer((_) async => const Right(null));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Right(null));
    });

    test('should return ValidationFailure when full name is empty', () async {
      // arrange
      const tParamsEmptyName = CompleteRegistrationParams(
        fullName: '',
        governorate: tGovernorate,
        district: tDistrict,
      );

      // act
      final result = await usecase(tParamsEmptyName);

      // assert
      expect(result, const Left(ValidationFailure(message: 'الاسم الكامل مطلوب')));
      verifyNever(mockAuthRepository.updateProfile(
        name: anyNamed('name'),
        governorate: anyNamed('governorate'),
        district: anyNamed('district'),
      ));
    });

    test('should return ValidationFailure when full name is only spaces', () async {
      // arrange
      const tParamsSpacesName = CompleteRegistrationParams(
        fullName: '   ',
        governorate: tGovernorate,
        district: tDistrict,
      );

      // act
      final result = await usecase(tParamsSpacesName);

      // assert
      expect(result, const Left(ValidationFailure(message: 'الاسم الكامل مطلوب')));
    });

    test('should return ValidationFailure when full name is invalid', () async {
      // arrange
      const tParamsInvalidName = CompleteRegistrationParams(
        fullName: 'A', // Too short
        governorate: tGovernorate,
        district: tDistrict,
      );

      // act
      final result = await usecase(tParamsInvalidName);

      // assert
      expect(result, const Left(ValidationFailure(
        message: 'الاسم غير صحيح. يجب أن يحتوي على حروف فقط ولا يقل عن حرفين',
      )));
    });

    test('should return ValidationFailure when governorate is empty', () async {
      // arrange
      const tParamsEmptyGovernorate = CompleteRegistrationParams(
        fullName: tFullName,
        governorate: '',
        district: tDistrict,
      );

      // act
      final result = await usecase(tParamsEmptyGovernorate);

      // assert
      expect(result, const Left(ValidationFailure(message: 'المحافظة مطلوبة')));
    });

    test('should return ValidationFailure when district is empty', () async {
      // arrange
      const tParamsEmptyDistrict = CompleteRegistrationParams(
        fullName: tFullName,
        governorate: tGovernorate,
        district: '',
      );

      // act
      final result = await usecase(tParamsEmptyDistrict);

      // assert
      expect(result, const Left(ValidationFailure(message: 'القضاء مطلوب')));
    });

    test('should return ServerFailure when repository returns ServerFailure', () async {
      // arrange
      const tServerFailure = ServerFailure(message: 'Server error');
      when(mockAuthRepository.updateProfile(
        name: anyNamed('name'),
        governorate: anyNamed('governorate'),
        district: anyNamed('district'),
      )).thenAnswer((_) async => const Left(tServerFailure));

      // act
      final result = await usecase(tParams);

      // assert
      expect(result, const Left(tServerFailure));
    });

    test('should trim whitespace from parameters before validation', () async {
      // arrange
      const tParamsWithSpaces = CompleteRegistrationParams(
        fullName: '  أحمد محمد علي  ',
        governorate: '  بغداد  ',
        district: '  الرصافة  ',
      );
      when(mockAuthRepository.updateProfile(
        name: anyNamed('name'),
        governorate: anyNamed('governorate'),
        district: anyNamed('district'),
      )).thenAnswer((_) async => const Right(null));

      // act
      await usecase(tParamsWithSpaces);

      // assert
      verify(mockAuthRepository.updateProfile(
        name: 'أحمد محمد علي',
        governorate: 'بغداد',
        district: 'الرصافة',
      ));
    });
  });
}
