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

class PricingError extends PricingState {
  final String message;

  const PricingError({required this.message});

  @override
  List<Object?> get props => [message];
}
