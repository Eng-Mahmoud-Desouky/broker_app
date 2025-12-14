import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../entities/order.dart';
import '../entities/shipping_method.dart';

/// Order repository interface
abstract class OrderRepository {
  /// Create new order from cart items
  Future<Either<Failure, Order>> createOrder({
    required List<CartItem> cartItems,
    required String addressId,
    required ShippingMethod shippingMethod,
  });

  /// Get all orders for current user
  Future<Either<Failure, List<Order>>> getUserOrders();

  /// Get order by ID
  Future<Either<Failure, Order>> getOrderById(String orderId);

  /// Get order by reference number
  Future<Either<Failure, Order>> getOrderByReference(String referenceNumber);

  /// Cancel order (if possible)
  Future<Either<Failure, void>> cancelOrder(String orderId);
}
