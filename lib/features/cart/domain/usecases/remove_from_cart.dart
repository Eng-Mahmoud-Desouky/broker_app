import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cart_repository.dart';

/// Use case for removing item from cart
class RemoveFromCart implements UseCase<void, RemoveFromCartParams> {
  final CartRepository repository;

  RemoveFromCart(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveFromCartParams params) async {
    return await repository.removeFromCart(params.itemId);
  }
}

class RemoveFromCartParams extends Equatable {
  final String itemId;

  const RemoveFromCartParams({required this.itemId});

  @override
  List<Object> get props => [itemId];
}

