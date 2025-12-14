part of 'order_bloc.dart';

/// Order states
abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class OrderInitial extends OrderState {}

/// Creating order
class OrderCreating extends OrderState {}

/// Order created successfully
class OrderCreated extends OrderState {
  final Order order;

  const OrderCreated({required this.order});

  @override
  List<Object?> get props => [order];
}

/// Loading orders
class OrderLoading extends OrderState {}

/// Orders loaded
class OrdersLoaded extends OrderState {
  final List<Order> orders;

  const OrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

/// No orders
class OrderEmpty extends OrderState {}

/// Error state
class OrderError extends OrderState {
  final String message;

  const OrderError({required this.message});

  @override
  List<Object?> get props => [message];
}
