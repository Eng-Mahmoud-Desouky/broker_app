import '../../domain/entities/order_item.dart';

/// Order item model for data layer
class OrderItemModel extends OrderItem {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.productName,
    required super.productUrl,
    required super.platform,
    required super.price,
    required super.quantity,
    required super.weightKg,
    super.imageUrl,
    super.metadata,
    required super.createdAt,
  });

  /// Create from Supabase JSON
  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json['id'] as String,
      orderId: json['order_id'] as String,
      productName: json['product_name'] as String,
      productUrl: json['product_url'] as String,
      platform: json['platform'] as String,
      price: json['price'] as String,
      quantity: json['quantity'] as int,
      weightKg:
          json['weight_kg'] != null
              ? (json['weight_kg'] as num).toDouble()
              : 0.01, // Default weight if null
      imageUrl: json['image_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Convert to JSON for Supabase insert
  Map<String, dynamic> toInsertJson() {
    return {
      'order_id': orderId,
      'product_name': productName,
      'product_url': productUrl,
      'platform': platform,
      'price': price,
      'quantity': quantity,
      'weight_kg': weightKg,
      'image_url': imageUrl,
      'metadata': metadata,
    };
  }
}
