import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

class GetCurrentSession implements UseCase<AuthSession?, NoParams> {
  final AuthRepository repository;

  GetCurrentSession(this.repository);

  @override
  Future<Either<Failure, AuthSession?>> call(NoParams params) async {
    return await repository.getCurrentSession();
  }
}
