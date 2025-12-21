import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/order.dart';
import '../repositories/order_repository.dart';

/// Use case for getting a single order by ID
class GetOrderById implements UseCase<Order, GetOrderByIdParams> {
  final OrderRepository repository;

  GetOrderById(this.repository);

  @override
  Future<Either<Failure, Order>> call(GetOrderByIdParams params) async {
    return await repository.getOrderById(params.orderId);
  }
}

/// Parameters for GetOrderById usecase
class GetOrderByIdParams {
  final String orderId;

  GetOrderByIdParams({required this.orderId});
}
