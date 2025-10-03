import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetSuggestedProducts implements UseCase<List<Product>, NoParams> {
  final HomeRepository repository;

  GetSuggestedProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(NoParams params) async {
    return await repository.getSuggestedProducts();
  }
}
