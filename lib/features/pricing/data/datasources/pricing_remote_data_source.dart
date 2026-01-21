import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/pricing_settings_model.dart';
import '../models/order_pricing_result_model.dart';
import '../../../order/domain/entities/shipping_method.dart';

abstract class PricingRemoteDataSource {
  Future<PricingSettingsModel> getPricingSettings();
  Future<OrderPricingResultModel> calculateOrderPricing({
    required List<Map<String, dynamic>> items,
    required PricingSettingsModel settings,
    required ShippingMethod shippingMethod,
  });
}

class PricingRemoteDataSourceImpl implements PricingRemoteDataSource {
  final SupabaseClient supabaseClient;

  PricingRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<PricingSettingsModel> getPricingSettings() async {
    final response =
        await supabaseClient
            .from('pricing_settings')
            .select()
            .order('updated_at', ascending: false)
            .limit(1)
            .single();

    return PricingSettingsModel.fromJson(response);
  }

  @override
  Future<OrderPricingResultModel> calculateOrderPricing({
    required List<Map<String, dynamic>> items,
    required PricingSettingsModel settings,
    required ShippingMethod shippingMethod,
  }) async {
    final shippingMethodStr =
        shippingMethod == ShippingMethod.air ? 'air' : 'sea';

    final response = await supabaseClient.rpc(
      'calculate_order_pricing',
      params: {
        'p_items': items,
        'p_settings': settings.toJson(),
        'p_shipping_method': shippingMethodStr,
      },
    );

    return OrderPricingResultModel.fromJson(response as Map<String, dynamic>);
  }
}
