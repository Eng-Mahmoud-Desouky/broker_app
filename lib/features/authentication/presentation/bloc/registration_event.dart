part of 'registration_bloc.dart';

abstract class RegistrationEvent extends Equatable {
  const RegistrationEvent();

  @override
  List<Object> get props => [];
}

class RegistrationNameChanged extends RegistrationEvent {
  final String name;

  const RegistrationNameChanged(this.name);

  @override
  List<Object> get props => [name];
}

class RegistrationGovernorateSelected extends RegistrationEvent {
  final String governorate;

  const RegistrationGovernorateSelected(this.governorate);

  @override
  List<Object> get props => [governorate];
}

class RegistrationDistrictSelected extends RegistrationEvent {
  final String district;

  const RegistrationDistrictSelected(this.district);

  @override
  List<Object> get props => [district];
}

class RegistrationSubmitted extends RegistrationEvent {
  const RegistrationSubmitted();
}

class RegistrationGovernoatesLoaded extends RegistrationEvent {
  const RegistrationGovernoatesLoaded();
}
