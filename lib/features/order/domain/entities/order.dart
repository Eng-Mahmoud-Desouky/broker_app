import 'package:equatable/equatable.dart';

import '../../../address/domain/entities/user_address.dart';
import 'order_item.dart';
import 'order_status.dart';
import 'shipping_method.dart';

/// Order entity representing a customer order
class Order extends Equatable {
  final String id;
  final String userId;
  final String referenceNumber;
  final UserAddress shippingAddress; // Snapshot of address at order time
  final ShippingMethod shippingMethod;
  final double totalWeightKg;
  final double? totalPrice;
  final String currency;
  final OrderStatus status;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Order({
    required this.id,
    required this.userId,
    required this.referenceNumber,
    required this.shippingAddress,
    required this.shippingMethod,
    required this.totalWeightKg,
    this.totalPrice,
    required this.currency,
    required this.status,
    required this.items,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get total number of items in order
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Check if order can be cancelled
  bool get canBeCancelled {
    return status == OrderStatus.pending || status == OrderStatus.processing;
  }

  /// Check if order is in final state
  bool get isFinal {
    return status == OrderStatus.delivered || status == OrderStatus.cancelled;
  }

  /// Get status color based on order status
  String get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return '#FF9800'; // warning
      case OrderStatus.processing:
        return '#2196F3'; // info
      case OrderStatus.shipped:
        return '#FF9D2D'; // primary
      case OrderStatus.delivered:
        return '#4CAF50'; // success
      case OrderStatus.cancelled:
        return '#F44336'; // error
    }
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    referenceNumber,
    shippingAddress,
    shippingMethod,
    totalWeightKg,
    totalPrice,
    currency,
    status,
    items,
    createdAt,
    updatedAt,
  ];
}
