import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

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
  final double? discountAmount;
  final String? promoCodeUsed;

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
    this.discountAmount,
    this.promoCodeUsed,
  });

  /// Get total number of items in order
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  /// Check if order can be cancelled
  bool get canBeCancelled {
    return status.canBeCancelled;
  }

  /// Check if order is in final state
  bool get isFinal {
    return status.isCompleted;
  }

  /// Get status color based on order status
  Color get statusColor {
    return status.getStatusColor();
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
    discountAmount,
    promoCodeUsed,
  ];
}
