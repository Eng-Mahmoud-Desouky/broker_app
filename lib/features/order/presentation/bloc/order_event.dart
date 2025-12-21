part of 'order_bloc.dart';

/// Order events
abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

/// Create new order
class OrderCreate extends OrderEvent {
  final List<CartItem> cartItems;
  final String addressId;
  final ShippingMethod shippingMethod;

  const OrderCreate({
    required this.cartItems,
    required this.addressId,
    required this.shippingMethod,
  });

  @override
  List<Object?> get props => [cartItems, addressId, shippingMethod];
}

/// Load all user orders
class OrderLoadAll extends OrderEvent {
  const OrderLoadAll();

  @override
  List<Object?> get props => [];
}

/// Load single order by ID
class OrderLoadById extends OrderEvent {
  final String orderId;

  const OrderLoadById({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}
