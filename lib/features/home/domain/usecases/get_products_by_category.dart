import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/product.dart';
import '../repositories/home_repository.dart';

class GetProductsByCategory implements UseCase<List<Product>, GetProductsByCategoryParams> {
  final HomeRepository repository;

  GetProductsByCategory(this.repository);

  @override
  Future<Either<Failure, List<Product>>> call(GetProductsByCategoryParams params) async {
    return await repository.getProductsByCategory(params.categoryId);
  }
}

class GetProductsByCategoryParams extends Equatable {
  final String categoryId;

  const GetProductsByCategoryParams({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}
