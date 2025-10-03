import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetSimilarProducts implements UseCase<List<Product>, GetSimilarProductsParams> {
  final HomeRepository repository;

  GetSimilarProducts(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetSimilarProductsParams params) async {
    return await repository.getSimilarProducts(params.productId);
  }
}

class GetSimilarProductsParams extends Equatable {
  final String productId;

  const GetSimilarProductsParams({required this.productId});

  @override
  List<Object> get props => [productId];
}
