import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/platform_url.dart';

/// Use case for getting platform URL by platform ID
class GetPlatformUrl implements UseCase<PlatformUrl, GetPlatformUrlParams> {
  @override
  Future<Either<Failure, PlatformUrl>> call(GetPlatformUrlParams params) async {
    final platformUrl = PlatformUrls.getPlatformUrl(params.platformId);
    
    if (platformUrl == null) {
      return Left(CacheFailure(message: 'Platform URL not found for ${params.platformId}'));
    }
    
    return Right(platformUrl);
  }
}

class GetPlatformUrlParams {
  final String platformId;

  GetPlatformUrlParams({required this.platformId});
}
