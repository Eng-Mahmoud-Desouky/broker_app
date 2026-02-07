import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/auth_repository.dart';

class UpdateProfile implements UseCase<void, UpdateProfileParams> {
  final AuthRepository repository;

  UpdateProfile(this.repository);

  @override
  Future<Either<Failure, void>> call(UpdateProfileParams params) async {
    return await repository.updateProfile(
      name: params.name,
      email: params.email,
      profilePicture: params.profilePicture,
      governorate: params.governorate,
      district: params.district,
    );
  }
}

class UpdateProfileParams extends Equatable {
  final String? name;
  final String? email;
  final String? profilePicture;
  final String? governorate;
  final String? district;

  const UpdateProfileParams({
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
