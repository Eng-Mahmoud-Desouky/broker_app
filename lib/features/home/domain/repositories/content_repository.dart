import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/app_content.dart';

abstract class ContentRepository {
  Future<Either<Failure, AppContent>> getAppContent(String key);
}
