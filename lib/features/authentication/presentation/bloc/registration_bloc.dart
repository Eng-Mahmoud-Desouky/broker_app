import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/utils/validators.dart';
import '../../domain/usecases/complete_registration.dart';

part 'registration_event.dart';
part 'registration_state.dart';

class RegistrationBloc extends Bloc<RegistrationEvent, RegistrationState> {
  final CompleteRegistration completeRegistration;

  RegistrationBloc({
    required this.completeRegistration,
  }) : super(const RegistrationState()) {
    on<RegistrationNameChanged>(_onNameChanged);
    on<RegistrationGovernorateSelected>(_onGovernorateSelected);
    on<RegistrationDistrictSelected>(_onDistrictSelected);
    on<RegistrationSubmitted>(_onSubmitted);
    on<RegistrationGovernoatesLoaded>(_onGovernoatesLoaded);
  }

  void _onNameChanged(
    RegistrationNameChanged event,
    Emitter<RegistrationState> emit,
  ) {
    final name = event.name.trim();
    final isValidName = name.isNotEmpty && Validators.isValidName(name);
    
    emit(state.copyWith(
      fullName: name,
      isValidName: isValidName,
      nameError: isValidName ? null : _getNameError(name),
      formStatus: _getFormStatus(
        name: name,
        governorate: state.governorate,
        district: state.district,
      ),
    ));
  }

  void _onGovernorateSelected(
    RegistrationGovernorateSelected event,
    Emitter<RegistrationState> emit,
  ) {
    emit(state.copyWith(
      governorate: event.governorate,
      district: '', // Reset district when governorate changes
      isValidGovernorate: event.governorate.isNotEmpty,
      isValidDistrict: false,
      governorateError: null,
      districtError: null,
      formStatus: _getFormStatus(
        name: state.fullName,
        governorate: event.governorate,
        district: '',
      ),
    ));
  }

  void _onDistrictSelected(
    RegistrationDistrictSelected event,
    Emitter<RegistrationState> emit,
  ) {
    final isValidDistrict = event.district.isNotEmpty;
    
    emit(state.copyWith(
      district: event.district,
      isValidDistrict: isValidDistrict,
      districtError: isValidDistrict ? null : 'القضاء مطلوب',
      formStatus: _getFormStatus(
        name: state.fullName,
        governorate: state.governorate,
        district: event.district,
      ),
    ));
  }

  Future<void> _onSubmitted(
    RegistrationSubmitted event,
    Emitter<RegistrationState> emit,
  ) async {
    if (state.formStatus != RegistrationFormStatus.valid) {
      return;
    }

    emit(state.copyWith(formStatus: RegistrationFormStatus.submitting));

    final result = await completeRegistration(
      CompleteRegistrationParams(
        fullName: state.fullName,
        governorate: state.governorate,
        district: state.district,
      ),
    );

    result.fold(
      (failure) => emit(state.copyWith(
        formStatus: RegistrationFormStatus.failure,
        errorMessage: failure.message,
      )),
      (_) => emit(state.copyWith(
        formStatus: RegistrationFormStatus.success,
      )),
    );
  }

  Future<void> _onGovernoatesLoaded(
    RegistrationGovernoatesLoaded event,
    Emitter<RegistrationState> emit,
  ) async {
    try {
      final String response = await rootBundle.loadString('assets/data/governorates.json');
      final List<dynamic> data = json.decode(response);
      
      final governorates = data.map((item) => GovernorateData.fromJson(item)).toList();
      
      emit(state.copyWith(
        governorates: governorates,
        isLoadingGovernorates: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingGovernorates: false,
        errorMessage: 'فشل في تحميل بيانات المحافظات',
      ));
    }
  }

  String? _getNameError(String name) {
    if (name.isEmpty) {
      return 'الاسم الكامل مطلوب';
    }
    if (!Validators.isValidName(name)) {
      return 'الاسم غير صحيح. يجب أن يحتوي على حروف فقط ولا يقل عن حرفين';
    }
    return null;
  }

  RegistrationFormStatus _getFormStatus({
    required String name,
    required String governorate,
    required String district,
  }) {
    final isValidName = name.isNotEmpty && Validators.isValidName(name);
    final isValidGovernorate = governorate.isNotEmpty;
    final isValidDistrict = district.isNotEmpty;

    if (isValidName && isValidGovernorate && isValidDistrict) {
      return RegistrationFormStatus.valid;
    }
    return RegistrationFormStatus.initial;
  }
}

class GovernorateData extends Equatable {
  final String governorate;
  final List<String> districts;

  const GovernorateData({
    required this.governorate,
    required this.districts,
  });

  factory GovernorateData.fromJson(Map<String, dynamic> json) {
    return GovernorateData(
      governorate: json['governorate'] as String,
      districts: List<String>.from(json['districts'] as List),
    );
  }

  @override
  List<Object> get props => [governorate, districts];
}
