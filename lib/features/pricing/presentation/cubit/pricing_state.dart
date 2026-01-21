part of 'pricing_cubit.dart';

abstract class PricingState extends Equatable {
  const PricingState();

  @override
  List<Object?> get props => [];
}

class PricingInitial extends PricingState {}

class PricingLoading extends PricingState {}

class PricingLoaded extends PricingState {
  final PricingSettings settings;

  const PricingLoaded({required this.settings});

  @override
  List<Object?> get props => [settings];
}

class PricingCalculating extends PricingState {}

class PricingCalculated extends PricingState {
  final OrderPricingResult result;

  const PricingCalculated({required this.result});

  @override
  List<Object?> get props => [result];
}

class PricingError extends PricingState {
  final String message;

  const PricingError({required this.message});

  @override
  List<Object?> get props => [message];
}
