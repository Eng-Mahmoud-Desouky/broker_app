/// Order status enum
enum OrderStatus {
  /// معلق - Pending (order created, awaiting processing)
  pending('pending', 'معلق'),

  /// قيد التجهيز - Processing (order is being prepared)
  processing('processing', 'قيد التجهيز'),

  /// تم الشحن - Shipped (order has been shipped)
  shipped('shipped', 'تم الشحن'),

  /// تم التوصيل - Delivered (order has been delivered)
  delivered('delivered', 'تم التوصيل'),

  /// ملغي - Cancelled (order was cancelled)
  cancelled('cancelled', 'ملغي');

  final String value;
  final String arabicLabel;
  const OrderStatus(this.value, this.arabicLabel);

  /// Get order status from database value
  static OrderStatus fromString(String value) {
    return OrderStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => OrderStatus.pending,
    );
  }

  /// Convert to database value
  String toDbValue() => value;
}
