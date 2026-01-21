import '../entities/pricing_settings.dart';
import '../entities/order_pricing_result.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../order/domain/entities/shipping_method.dart';

abstract class PricingRepository {
  Future<PricingSettings> getPricingSettings();
  Future<OrderPricingResult> calculateOrderPricing({
    required List<CartItem> items,
    required PricingSettings settings,
    required ShippingMethod shippingMethod,
  });
}
