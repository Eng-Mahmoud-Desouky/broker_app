import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../entities/order.dart';
import '../entities/shipping_method.dart';
import '../repositories/order_repository.dart';

/// Create new order from cart items
class CreateOrder implements UseCase<Order, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrder(this.repository);

  @override
  Future<Either<Failure, Order>> call(CreateOrderParams params) async {
    return await repository.createOrder(
      cartItems: params.cartItems,
      addressId: params.addressId,
      shippingMethod: params.shippingMethod,
      promoCode: params.promoCode,
    );
  }
}

class CreateOrderParams extends Equatable {
  final List<CartItem> cartItems;
  final String addressId;
  final ShippingMethod shippingMethod;
  final String? promoCode;

  const CreateOrderParams({
    required this.cartItems,
    required this.addressId,
    required this.shippingMethod,
    this.promoCode,
  });

  @override
  List<Object?> get props => [cartItems, addressId, shippingMethod, promoCode];
}
