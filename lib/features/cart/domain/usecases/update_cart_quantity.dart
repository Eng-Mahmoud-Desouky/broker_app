import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cart_item.dart';
import '../repositories/cart_repository.dart';

/// Use case for updating cart item quantity
class UpdateCartQuantity implements UseCase<CartItem, UpdateCartQuantityParams> {
  final CartRepository repository;

  UpdateCartQuantity(this.repository);

  @override
  Future<Either<Failure, CartItem>> call(UpdateCartQuantityParams params) async {
    return await repository.updateQuantity(
      itemId: params.itemId,
      quantity: params.quantity,
    );
  }
}

class UpdateCartQuantityParams extends Equatable {
  final String itemId;
  final int quantity;

  const UpdateCartQuantityParams({
    required this.itemId,
    required this.quantity,
  });

  @override
  List<Object> get props => [itemId, quantity];
}

