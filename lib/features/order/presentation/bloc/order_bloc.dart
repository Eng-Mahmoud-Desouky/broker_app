import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/shipping_method.dart';
import '../../domain/usecases/create_order.dart';
import '../../domain/usecases/get_user_orders.dart';

part 'order_event.dart';
part 'order_state.dart';

/// Order BLoC for managing orders
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final CreateOrder createOrder;
  final GetUserOrders getUserOrders;

  OrderBloc({required this.createOrder, required this.getUserOrders})
    : super(OrderInitial()) {
    on<OrderCreate>(_onCreate);
    on<OrderLoadAll>(_onLoadAll);
  }

  Future<void> _onCreate(OrderCreate event, Emitter<OrderState> emit) async {
    emit(OrderCreating());

    final result = await createOrder(
      CreateOrderParams(
        cartItems: event.cartItems,
        addressId: event.addressId,
        shippingMethod: event.shippingMethod,
      ),
    );

    result.fold(
      (failure) => emit(OrderError(message: _mapFailureToMessage(failure))),
      (order) {
        emit(OrderCreated(order: order));
      },
    );
  }

  Future<void> _onLoadAll(OrderLoadAll event, Emitter<OrderState> emit) async {
    emit(OrderLoading());

    final result = await getUserOrders(NoParams());

    result.fold(
      (failure) => emit(OrderError(message: _mapFailureToMessage(failure))),
      (orders) {
        if (orders.isEmpty) {
          emit(OrderEmpty());
        } else {
          emit(OrdersLoaded(orders: orders));
        }
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is AuthenticationFailure) {
      return 'يرجى تسجيل الدخول أولاً';
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }
}
