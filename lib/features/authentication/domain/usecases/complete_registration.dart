import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../../core/utils/validators.dart';
import '../repositories/auth_repository.dart';

class CompleteRegistration implements UseCase<void, CompleteRegistrationParams> {
  final AuthRepository repository;

  CompleteRegistration(this.repository);

  @override
  Future<Either<Failure, void>> call(CompleteRegistrationParams params) async {
    // Validate full name
    if (params.fullName.trim().isEmpty) {
      return const Left(ValidationFailure(
        message: 'الاسم الكامل مطلوب',
      ));
    }

    if (!Validators.isValidName(params.fullName)) {
      return const Left(ValidationFailure(
        message: 'الاسم غير صحيح. يجب أن يحتوي على حروف فقط ولا يقل عن حرفين',
      ));
    }

    // Validate governorate
    if (params.governorate.trim().isEmpty) {
      return const Left(ValidationFailure(
        message: 'المحافظة مطلوبة',
      ));
    }

    // Validate district
    if (params.district.trim().isEmpty) {
      return const Left(ValidationFailure(
        message: 'القضاء مطلوب',
      ));
    }

    return await repository.updateProfile(
      name: params.fullName.trim(),
      governorate: params.governorate.trim(),
      district: params.district.trim(),
    );
  }
}

class CompleteRegistrationParams extends Equatable {
  final String fullName;
  final String governorate;
  final String district;

  const CompleteRegistrationParams({
    required this.fullName,
    required this.governorate,
    required this.district,
  });

  @override
  List<Object> get props => [fullName, governorate, district];
}
