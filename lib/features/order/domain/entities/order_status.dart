import 'package:flutter/material.dart';

/// Order status enum for tracking order progress through workflow
enum OrderStatus {
  /// قيد المراجعة - Under Review (order received, being reviewed)
  underReview('under_review', 'قيد المراجعة'),

  /// قيد الشراء - Purchasing (order is being purchased from suppliers)
  purchasing('purchasing', 'قيد الشراء'),

  /// تم الشراء - Purchased (order has been purchased)
  purchased('purchased', 'تم الشراء'),

  /// في المخزن الصيني - In China Warehouse (order is in Chinese warehouse)
  inChinaWarehouse('in_china_warehouse', 'في المخزن الصيني'),

  /// شحن إلى العراق - Shipping to Iraq (order is being shipped to Iraq)
  shippingToIraq('shipping_to_iraq', 'شحن إلى العراق'),

  /// في المخزن العراقي - In Iraq Warehouse (order has arrived in Iraq)
  inIraqWarehouse('in_iraq_warehouse', 'في المخزن العراقي'),

  /// جاهز للتسليم - Ready for Delivery (order is ready for customer pickup)
  readyForDelivery('ready_for_delivery', 'جاهز للتسليم'),

  /// تم التسليم - Delivered (order has been delivered to customer)
  delivered('delivered', 'تم التسليم'),

  /// ملغي - Cancelled (order was cancelled)
  cancelled('cancelled', 'ملغي');

  final String value;
  final String arabicLabel;
  const OrderStatus(this.value, this.arabicLabel);

  /// Get order status from database value
  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.underReview,
    );
  }

  /// Convert to database value
  String toDbValue() => value;

  /// Get color associated with this status
  Color getStatusColor() {
    switch (this) {
      case OrderStatus.underReview:
        return const Color(0xFFFF9800); // Orange - Warning
      case OrderStatus.purchasing:
        return const Color(0xFF2196F3); // Blue - Info
      case OrderStatus.purchased:
        return const Color(0xFF00BCD4); // Cyan - Success variant
      case OrderStatus.inChinaWarehouse:
        return const Color(0xFF9C27B0); // Purple
      case OrderStatus.shippingToIraq:
        return const Color(0xFFFF9D2D); // Primary orange
      case OrderStatus.inIraqWarehouse:
        return const Color(0xFF673AB7); // Deep Purple
      case OrderStatus.readyForDelivery:
        return const Color(0xFF4CAF50); // Green - Almost done
      case OrderStatus.delivered:
        return const Color(0xFF388E3C); // Dark Green - Success
      case OrderStatus.cancelled:
        return const Color(0xFFF44336); // Red - Error
    }
  }

  /// Get icon associated with this status
  IconData getStatusIcon() {
    switch (this) {
      case OrderStatus.underReview:
        return Icons.rate_review;
      case OrderStatus.purchasing:
        return Icons.shopping_cart;
      case OrderStatus.purchased:
        return Icons.check_circle_outline;
      case OrderStatus.inChinaWarehouse:
        return Icons.warehouse;
      case OrderStatus.shippingToIraq:
        return Icons.local_shipping;
      case OrderStatus.inIraqWarehouse:
        return Icons.store;
      case OrderStatus.readyForDelivery:
        return Icons.done_all;
      case OrderStatus.delivered:
        return Icons.verified;
      case OrderStatus.cancelled:
        return Icons.cancel;
    }
  }

  /// Get detailed description for this status
  String getStatusDescription() {
    switch (this) {
      case OrderStatus.underReview:
        return 'تم استلام طلبك وجاري المراجعة';
      case OrderStatus.purchasing:
        return 'جاري شراء المنتجات من المتاجر الصينية';
      case OrderStatus.purchased:
        return 'تم إتمام عملية الشراء بنجاح';
      case OrderStatus.inChinaWarehouse:
        return 'وصلت المنتجات إلى المخزن الصيني';
      case OrderStatus.shippingToIraq:
        return 'جاري شحن الطلب إلى العراق';
      case OrderStatus.inIraqWarehouse:
        return 'وصل طلبك إلى المخزن في العراق';
      case OrderStatus.readyForDelivery:
        return 'طلبك جاهز للاستلام';
      case OrderStatus.delivered:
        return 'تم تسليم الطلب بنجاح';
      case OrderStatus.cancelled:
        return 'تم إلغاء الطلب';
    }
  }

  /// Check if this status is a final state (no more updates expected)
  bool get isCompleted {
    return this == OrderStatus.delivered || this == OrderStatus.cancelled;
  }

  /// Check if order can be cancelled in this status
  bool get canBeCancelled {
    return this == OrderStatus.underReview ||
        this == OrderStatus.purchasing ||
        this == OrderStatus.purchased;
  }

  /// Get progress index for timeline (0-based)
  /// Returns -1 for cancelled status
  int get progressIndex {
    if (this == OrderStatus.cancelled) return -1;
    return index;
  }

  /// Get total number of progress steps (excluding cancelled)
  static int get totalProgressSteps => 8;

  /// Get all non-cancelled statuses in order
  static List<OrderStatus> get progressStatuses {
    return OrderStatus.values.where((s) => s != OrderStatus.cancelled).toList();
  }
}
