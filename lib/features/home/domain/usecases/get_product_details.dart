import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetProductDetails implements UseCase<Product, GetProductDetailsParams> {
  final HomeRepository repository;

  GetProductDetails(this.repository);

  @override
  Future<Either<Failure, Product>> call(GetProductDetailsParams params) async {
    return await repository.getProductById(params.productId);
  }
}

class GetProductDetailsParams extends Equatable {
  final String productId;

  const GetProductDetailsParams({required this.productId});

  @override
  List<Object> get props => [productId];
}
