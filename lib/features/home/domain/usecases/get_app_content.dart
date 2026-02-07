import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/app_content.dart';
import '../repositories/content_repository.dart';

class GetAppContent implements UseCase<AppContent, GetAppContentParams> {
  final ContentRepository repository;

  GetAppContent(this.repository);

  @override
  Future<Either<Failure, AppContent>> call(GetAppContentParams params) async {
    return await repository.getAppContent(params.key);
  }
}

class GetAppContentParams extends Equatable {
  final String key;

  const GetAppContentParams({required this.key});

  @override
  List<Object?> get props => [key];
}
