import '../entities/pricing_settings.dart';

abstract class PricingRepository {
  Future<PricingSettings> getPricingSettings();
}
