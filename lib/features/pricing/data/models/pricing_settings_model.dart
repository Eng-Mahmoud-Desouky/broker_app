import '../../../../core/currency/currency_service.dart';
import '../../domain/entities/pricing_settings.dart';

class PricingSettingsModel extends PricingSettings {
  const PricingSettingsModel({
    required super.id,
    required super.brokerCommissionPercent,
    required super.airFreightPricePerKg,
    required super.seaFreightPricePerKg,
    required super.updatedAt,
  });

  factory PricingSettingsModel.fromJson(Map<String, dynamic> json) {
    return PricingSettingsModel(
      id: json['id'] as String,
      brokerCommissionPercent: CurrencyService.toDouble(
        json['broker_commission_percent'],
      ),
      airFreightPricePerKg: CurrencyService.toDouble(
        json['air_freight_price_per_kg'],
      ),
      seaFreightPricePerKg: CurrencyService.toDouble(
        json['sea_freight_price_per_kg'],
      ),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'broker_commission_percent': brokerCommissionPercent,
      'air_freight_price_per_kg': airFreightPricePerKg,
      'sea_freight_price_per_kg': seaFreightPricePerKg,
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
