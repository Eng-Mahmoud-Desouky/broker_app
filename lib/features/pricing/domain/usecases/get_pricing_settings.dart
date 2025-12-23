import '../entities/pricing_settings.dart';
import '../repositories/pricing_repository.dart';

class GetPricingSettings {
  final PricingRepository repository;

  GetPricingSettings(this.repository);

  Future<PricingSettings> call() async {
    return await repository.getPricingSettings();
  }
}
