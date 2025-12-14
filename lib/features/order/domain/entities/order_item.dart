import 'package:equatable/equatable.dart';

/// Order item entity representing a product in an order
class OrderItem extends Equatable {
  final String id;
  final String orderId;
  final String productName;
  final String productUrl;
  final String platform;
  final String price;
  final int quantity;
  final double weightKg;
  final String? imageUrl;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  const OrderItem({
    required this.id,
    required this.orderId,
    required this.productName,
    required this.productUrl,
    required this.platform,
    required this.price,
    required this.quantity,
    required this.weightKg,
    this.imageUrl,
    this.metadata,
    required this.createdAt,
  });

  /// Get total weight for this item (weight * quantity)
  double get totalWeight => weightKg * quantity;

  /// Parse price to double if possible
  double? get priceValue {
    try {
      final numericString = price.replaceAll(RegExp(r'[^\d.]'), '');
      return double.tryParse(numericString);
    } catch (e) {
      return null;
    }
  }

  /// Get total price for this item (price * quantity)
  double? get totalPrice {
    final pv = priceValue;
    return pv != null ? pv * quantity : null;
  }

  @override
  List<Object?> get props => [
    id,
    orderId,
    productName,
    productUrl,
    platform,
    price,
    quantity,
    weightKg,
    imageUrl,
    metadata,
    createdAt,
  ];
}
