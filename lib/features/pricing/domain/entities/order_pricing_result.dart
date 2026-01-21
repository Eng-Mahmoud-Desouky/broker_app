import 'package:equatable/equatable.dart';

/// Entity representing the result of order pricing calculation
class OrderPricingResult extends Equatable {
  final double subtotal;
  final double commission;
  final double shippingCost;
  final double total;
  final bool isEstimatedShipping;
  final bool missingShippingData;

  const OrderPricingResult({
    required this.subtotal,
    required this.commission,
    required this.shippingCost,
    required this.total,
    required this.isEstimatedShipping,
    required this.missingShippingData,
  });

  @override
  List<Object?> get props => [
    subtotal,
    commission,
    shippingCost,
    total,
    isEstimatedShipping,
    missingShippingData,
  ];
}
