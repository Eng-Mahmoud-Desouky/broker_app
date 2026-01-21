import '../../domain/entities/order_pricing_result.dart';

class OrderPricingResultModel extends OrderPricingResult {
  const OrderPricingResultModel({
    required super.subtotal,
    required super.commission,
    required super.shippingCost,
    required super.total,
    required super.isEstimatedShipping,
    required super.missingShippingData,
  });

  factory OrderPricingResultModel.fromJson(Map<String, dynamic> json) {
    return OrderPricingResultModel(
      subtotal: (json['subtotal'] as num).toDouble(),
      commission: (json['commission'] as num).toDouble(),
      shippingCost: (json['shipping_cost'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      isEstimatedShipping: json['is_estimated_shipping'] as bool,
      missingShippingData: json['missing_shipping_data'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subtotal': subtotal,
      'commission': commission,
      'shipping_cost': shippingCost,
      'total': total,
      'is_estimated_shipping': isEstimatedShipping,
      'missing_shipping_data': missingShippingData,
    };
  }
}
