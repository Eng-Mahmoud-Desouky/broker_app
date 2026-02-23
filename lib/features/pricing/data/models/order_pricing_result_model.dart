import '../../../../core/currency/currency_service.dart';
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
      subtotal: CurrencyService.toDouble(json['subtotal']),
      commission: CurrencyService.toDouble(json['commission']),
      shippingCost: CurrencyService.toDouble(json['shipping_cost']),
      total: CurrencyService.toDouble(json['total']),
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
