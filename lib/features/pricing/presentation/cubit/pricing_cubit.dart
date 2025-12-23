import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../../order/domain/entities/shipping_method.dart';
import '../../domain/entities/pricing_settings.dart';
import '../../domain/usecases/get_pricing_settings.dart';

part 'pricing_state.dart';

class PricingCubit extends Cubit<PricingState> {
  final GetPricingSettings getPricingSettings;

  PricingCubit({required this.getPricingSettings}) : super(PricingInitial());

  Future<void> fetchPricingSettings() async {
    emit(PricingLoading());
    try {
      final settings = await getPricingSettings();
      emit(PricingLoaded(settings: settings));
    } catch (e) {
      emit(PricingError(message: e.toString()));
    }
  }

  double calculateExpectedTotal({
    required List<CartItem> items,
    required PricingSettings settings,
    required ShippingMethod shippingMethod,
  }) {
    double subtotal = 0;
    double totalWeight = 0;

    for (final item in items) {
      final price = item.priceValue ?? 0;
      subtotal += price * item.quantity;
      totalWeight += (item.weightKg ?? 0) * item.quantity;
    }

    final shippingRate =
        (shippingMethod == ShippingMethod.air)
            ? settings.airFreightPricePerKg
            : settings.seaFreightPricePerKg;

    final shippingCost = totalWeight * shippingRate;
    final commission =
        (subtotal + shippingCost) * (settings.brokerCommissionPercent / 100);

    return subtotal + shippingCost + commission;
  }
}
