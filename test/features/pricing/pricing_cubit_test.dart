import 'package:flutter_test/flutter_test.dart';
import 'package:broker_app/features/pricing/presentation/cubit/pricing_cubit.dart';
import 'package:broker_app/features/pricing/domain/entities/pricing_settings.dart';
import 'package:broker_app/features/cart/domain/entities/cart_item.dart';
import 'package:broker_app/features/order/domain/entities/shipping_method.dart';
import 'package:mocktail/mocktail.dart';
import 'package:broker_app/features/pricing/domain/usecases/get_pricing_settings.dart';

class MockGetPricingSettings extends Mock implements GetPricingSettings {}

void main() {
  late PricingCubit cubit;
  late MockGetPricingSettings mockGetPricingSettings;

  setUp(() {
    mockGetPricingSettings = MockGetPricingSettings();
    cubit = PricingCubit(getPricingSettings: mockGetPricingSettings);
  });

  group('calculateExpectedTotal', () {
    final settings = PricingSettings(
      id: '1',
      brokerCommissionPercent: 10.0, // 10%
      airFreightPricePerKg: 15.0,
      seaFreightPricePerKg: 5.0,
      updatedAt: DateTime.now(),
    );

    final cartItems = [
      CartItem(
        id: '1',
        userId: 'user1',
        productName: 'Item 1',
        price: 100.0,
        productUrl: '',
        platform: 'amazon',
        quantity: 2,
        weightKg: 1.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      CartItem(
        id: '2',
        userId: 'user1',
        productName: 'Item 2',
        price: 50.0,
        productUrl: '',
        platform: 'aliexpress',
        quantity: 1,
        weightKg: 2.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];

    test('calculates correct total for AIR shipping', () {
      // Subtotal = (100 * 2) + (50 * 1) = 250
      // Total Weight = (1 * 2) + (2 * 1) = 4 kg
      // Shipping Cost = 4 * 15 = 60
      // Commission = (250 + 60) * 0.10 = 31
      // Expected Total = 250 + 60 + 31 = 341

      final result = cubit.calculateExpectedTotal(
        items: cartItems,
        settings: settings,
        shippingMethod: ShippingMethod.air,
      );

      expect(result, 341.0);
    });

    test('calculates correct total for SEA shipping', () {
      // Subtotal = 250
      // Total Weight = 4 kg
      // Shipping Cost = 4 * 5 = 20
      // Commission = (250 + 20) * 0.10 = 27
      // Expected Total = 250 + 20 + 27 = 297

      final result = cubit.calculateExpectedTotal(
        items: cartItems,
        settings: settings,
        shippingMethod: ShippingMethod.sea,
      );

      expect(result, 297.0);
    });
  });
}
