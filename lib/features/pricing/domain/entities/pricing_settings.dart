import 'package:equatable/equatable.dart';

class PricingSettings extends Equatable {
  final String id;
  final double brokerCommissionPercent;
  final double airFreightPricePerKg;
  final double seaFreightPricePerKg;
  final DateTime updatedAt;

  const PricingSettings({
    required this.id,
    required this.brokerCommissionPercent,
    required this.airFreightPricePerKg,
    required this.seaFreightPricePerKg,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    brokerCommissionPercent,
    airFreightPricePerKg,
    seaFreightPricePerKg,
    updatedAt,
  ];
}
