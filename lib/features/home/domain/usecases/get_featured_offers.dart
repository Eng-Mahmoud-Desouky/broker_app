import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/offer.dart';
import '../repositories/home_repository.dart';

class GetFeaturedOffers implements UseCase<List<Offer>, NoParams> {
  final HomeRepository repository;

  GetFeaturedOffers(this.repository);

  @override
  Future<Either<Failure, List<Offer>>> call(NoParams params) async {
    return await repository.getFeaturedOffers();
  }
}
