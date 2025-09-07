part of 'registration_bloc.dart';

enum RegistrationFormStatus {
  initial,
  valid,
  submitting,
  success,
  failure,
}

class RegistrationState extends Equatable {
  final String fullName;
  final String governorate;
  final String district;
  final bool isValidName;
  final bool isValidGovernorate;
  final bool isValidDistrict;
  final String? nameError;
  final String? governorateError;
  final String? districtError;
  final RegistrationFormStatus formStatus;
  final String? errorMessage;
  final List<GovernorateData> governorates;
  final bool isLoadingGovernorates;

  const RegistrationState({
    this.fullName = '',
    this.governorate = '',
    this.district = '',
    this.isValidName = false,
    this.isValidGovernorate = false,
    this.isValidDistrict = false,
    this.nameError,
    this.governorateError,
    this.districtError,
    this.formStatus = RegistrationFormStatus.initial,
    this.errorMessage,
    this.governorates = const [],
    this.isLoadingGovernorates = true,
  });

  List<String> get availableDistricts {
    if (governorate.isEmpty) return [];
    
    final selectedGovernorate = governorates.firstWhere(
      (gov) => gov.governorate == governorate,
      orElse: () => const GovernorateData(governorate: '', districts: []),
    );
    
    return selectedGovernorate.districts;
  }

  RegistrationState copyWith({
    String? fullName,
    String? governorate,
    String? district,
    bool? isValidName,
    bool? isValidGovernorate,
    bool? isValidDistrict,
    String? nameError,
    String? governorateError,
    String? districtError,
    RegistrationFormStatus? formStatus,
    String? errorMessage,
    List<GovernorateData>? governorates,
    bool? isLoadingGovernorates,
  }) {
    return RegistrationState(
      fullName: fullName ?? this.fullName,
      governorate: governorate ?? this.governorate,
      district: district ?? this.district,
      isValidName: isValidName ?? this.isValidName,
      isValidGovernorate: isValidGovernorate ?? this.isValidGovernorate,
      isValidDistrict: isValidDistrict ?? this.isValidDistrict,
      nameError: nameError ?? this.nameError,
      governorateError: governorateError ?? this.governorateError,
      districtError: districtError ?? this.districtError,
      formStatus: formStatus ?? this.formStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      governorates: governorates ?? this.governorates,
      isLoadingGovernorates: isLoadingGovernorates ?? this.isLoadingGovernorates,
    );
  }

  @override
  List<Object?> get props => [
        fullName,
        governorate,
        district,
        isValidName,
        isValidGovernorate,
        isValidDistrict,
        nameError,
        governorateError,
        districtError,
        formStatus,
        errorMessage,
        governorates,
        isLoadingGovernorates,
      ];
}
