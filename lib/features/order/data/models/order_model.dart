import '../../../../core/currency/currency_service.dart';
import '../../../address/data/models/user_address_model.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/order_status.dart';
import '../../domain/entities/shipping_method.dart';
import 'order_item_model.dart';

/// Order model for data layer
class OrderModel extends Order {
  const OrderModel({
    required super.id,
    required super.userId,
    required super.referenceNumber,
    required super.shippingAddress,
    required super.shippingMethod,
    required super.totalWeightKg,
    super.totalPrice,
    required super.currency,
    required super.status,
    required super.items,
    required super.createdAt,
    required super.updatedAt,
    super.discountAmount,
    super.promoCodeUsed,
  });

  /// Create from Supabase JSON (without items)
  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      referenceNumber: json['reference_number'] as String,
      shippingAddress: UserAddressModel.fromJson(
        json['shipping_address'] as Map<String, dynamic>,
      ),
      shippingMethod: ShippingMethod.fromString(
        json['shipping_method'] as String,
      ),
      totalWeightKg: CurrencyService.toDouble(json['total_weight_kg']),
      totalPrice: CurrencyService.toDoubleOrNull(json['total_price']),
      currency: json['currency'] as String? ?? 'USD',
      status: OrderStatus.fromString(json['status'] as String),
      items: const [], // Items loaded separately
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      discountAmount: CurrencyService.toDoubleOrNull(json['discount_amount']),
      promoCodeUsed: json['promo_code_used'] as String?,
    );
  }

  /// Create from JSON with items included
  factory OrderModel.fromJsonWithItems(
    Map<String, dynamic> json,
    List<OrderItemModel> items,
  ) {
    return OrderModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      referenceNumber: json['reference_number'] as String,
      shippingAddress: UserAddressModel.fromJson(
        json['shipping_address'] as Map<String, dynamic>,
      ),
      shippingMethod: ShippingMethod.fromString(
        json['shipping_method'] as String,
      ),
      totalWeightKg: CurrencyService.toDouble(json['total_weight_kg']),
      totalPrice: CurrencyService.toDoubleOrNull(json['total_price']),
      currency: json['currency'] as String? ?? 'USD',
      status: OrderStatus.fromString(json['status'] as String),
      items: items,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      discountAmount: CurrencyService.toDoubleOrNull(json['discount_amount']),
      promoCodeUsed: json['promo_code_used'] as String?,
    );
  }

  /// Convert to JSON for Supabase insert
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'reference_number': referenceNumber,
      'shipping_address': shippingAddress.toJson(),
      'shipping_method': shippingMethod.toDbValue(),
      'total_weight_kg': totalWeightKg,
      'total_price': totalPrice,
      'currency': currency,
      'status': status.toDbValue(),
    };
  }

  /// Update with items
  OrderModel copyWithItems(List<OrderItemModel> items) {
    return OrderModel(
      id: id,
      userId: userId,
      referenceNumber: referenceNumber,
      shippingAddress: shippingAddress,
      shippingMethod: shippingMethod,
      totalWeightKg: totalWeightKg,
      totalPrice: totalPrice,
      currency: currency,
      status: status,
      items: items,
      createdAt: createdAt,
      updatedAt: updatedAt,
      discountAmount: discountAmount,
      promoCodeUsed: promoCodeUsed,
    );
  }
}
