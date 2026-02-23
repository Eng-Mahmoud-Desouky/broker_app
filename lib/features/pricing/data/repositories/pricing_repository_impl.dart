import '../../domain/entities/pricing_settings.dart';
import '../../domain/entities/order_pricing_result.dart';
import '../../domain/repositories/pricing_repository.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../order/domain/entities/shipping_method.dart';
import '../datasources/pricing_remote_data_source.dart';

class PricingRepositoryImpl implements PricingRepository {
  final PricingRemoteDataSource remoteDataSource;

  PricingRepositoryImpl({required this.remoteDataSource});

  @override
  Future<PricingSettings> getPricingSettings() async {
    return await remoteDataSource.getPricingSettings();
  }

  @override
  Future<OrderPricingResult> calculateOrderPricing({
    required List<CartItem> items,
    required PricingSettings settings,
    required ShippingMethod shippingMethod,
  }) async {
    // Convert cart items to JSON format expected by RPC
    final itemsJson =
        items.map((item) {
          return {
            'price': item.price,
            'quantity': item.quantity,
            'platform': item.platform,
            'weight': item.weightKg,
            'length': item.dimensions?['length'],
            'width': item.dimensions?['width'],
            'height': item.dimensions?['height'],
          };
        }).toList();

    // Call the remote data source
    return await remoteDataSource.calculateOrderPricing(
      items: itemsJson,
      settings:
          settings as dynamic, // Will be PricingSettingsModel from data layer
      shippingMethod: shippingMethod,
    );
  }
}
