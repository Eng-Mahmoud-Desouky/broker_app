import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/platform.dart';
import '../repositories/home_repository.dart';

class GetPlatforms implements UseCase<List<Platform>, NoParams> {
  final HomeRepository repository;

  GetPlatforms(this.repository);

  @override
  Future<Either<Failure, List<Platform>>> call(NoParams params) async {
    return await repository.getPlatforms();
  }
}
