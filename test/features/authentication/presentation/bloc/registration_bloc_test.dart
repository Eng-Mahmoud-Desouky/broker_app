import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:broker_app/core/error/failures.dart';
import 'package:broker_app/features/authentication/domain/usecases/complete_registration.dart';
import 'package:broker_app/features/authentication/presentation/bloc/registration_bloc.dart';

import 'package:broker_app/core/services/notifications_service.dart';

import 'registration_bloc_test.mocks.dart';

@GenerateMocks([CompleteRegistration, NotificationsService])
void main() {
  late RegistrationBloc bloc;
  late MockCompleteRegistration mockCompleteRegistration;
  late MockNotificationsService mockNotificationsService;

  setUp(() {
    mockCompleteRegistration = MockCompleteRegistration();
    mockNotificationsService = MockNotificationsService();
    bloc = RegistrationBloc(
      completeRegistration: mockCompleteRegistration,
      notificationsService: mockNotificationsService,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('RegistrationBloc', () {
    test('initial state should be RegistrationState with default values', () {
      expect(bloc.state, const RegistrationState());
    });

    group('RegistrationNameChanged', () {
      blocTest<RegistrationBloc, RegistrationState>(
        'should emit state with updated name and validation',
        build: () => bloc,
        act: (bloc) => bloc.add(const RegistrationNameChanged('أحمد محمد')),
        expect:
            () => [
              const RegistrationState(
                fullName: 'أحمد محمد',
                isValidName: true,
                formStatus: RegistrationFormStatus.initial,
              ),
            ],
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'should emit state with error when name is invalid',
        build: () => bloc,
        act: (bloc) => bloc.add(const RegistrationNameChanged('A')),
        expect:
            () => [
              const RegistrationState(
                fullName: 'A',
                isValidName: false,
                nameError:
                    'الاسم غير صحيح. يجب أن يحتوي على حروف فقط ولا يقل عن حرفين',
                formStatus: RegistrationFormStatus.initial,
              ),
            ],
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'should emit state with error when name is empty',
        build: () => bloc,
        act: (bloc) => bloc.add(const RegistrationNameChanged('')),
        expect:
            () => [
              const RegistrationState(
                fullName: '',
                isValidName: false,
                nameError: 'الاسم الكامل مطلوب',
                formStatus: RegistrationFormStatus.initial,
              ),
            ],
      );
    });

    group('RegistrationGovernorateSelected', () {
      blocTest<RegistrationBloc, RegistrationState>(
        'should emit state with updated governorate and reset district',
        build: () => bloc,
        seed:
            () => const RegistrationState(
              governorate: 'old_governorate',
              district: 'old_district',
              isValidDistrict: true,
            ),
        act: (bloc) => bloc.add(const RegistrationGovernorateSelected('بغداد')),
        expect:
            () => [
              const RegistrationState(
                governorate: 'بغداد',
                district: '',
                isValidGovernorate: true,
                isValidDistrict: false,
                formStatus: RegistrationFormStatus.initial,
              ),
            ],
      );
    });

    group('RegistrationDistrictSelected', () {
      blocTest<RegistrationBloc, RegistrationState>(
        'should emit state with updated district and validation',
        build: () => bloc,
        act: (bloc) => bloc.add(const RegistrationDistrictSelected('الرصافة')),
        expect:
            () => [
              const RegistrationState(
                district: 'الرصافة',
                isValidDistrict: true,
                formStatus: RegistrationFormStatus.initial,
              ),
            ],
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'should emit valid form status when all fields are valid',
        build: () => bloc,
        seed:
            () => const RegistrationState(
              fullName: 'أحمد محمد',
              governorate: 'بغداد',
              isValidName: true,
              isValidGovernorate: true,
            ),
        act: (bloc) => bloc.add(const RegistrationDistrictSelected('الرصافة')),
        expect:
            () => [
              const RegistrationState(
                fullName: 'أحمد محمد',
                governorate: 'بغداد',
                district: 'الرصافة',
                isValidName: true,
                isValidGovernorate: true,
                isValidDistrict: true,
                formStatus: RegistrationFormStatus.valid,
              ),
            ],
      );
    });

    group('RegistrationSubmitted', () {
      const tValidState = RegistrationState(
        fullName: 'أحمد محمد',
        governorate: 'بغداد',
        district: 'الرصافة',
        isValidName: true,
        isValidGovernorate: true,
        isValidDistrict: true,
        formStatus: RegistrationFormStatus.valid,
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'should emit success when registration completes successfully',
        build: () {
          when(
            mockCompleteRegistration(any),
          ).thenAnswer((_) async => const Right(null));
          return bloc;
        },
        seed: () => tValidState,
        act: (bloc) => bloc.add(const RegistrationSubmitted()),
        expect:
            () => [
              tValidState.copyWith(
                formStatus: RegistrationFormStatus.submitting,
              ),
              tValidState.copyWith(formStatus: RegistrationFormStatus.success),
            ],
        verify: (_) {
          verify(
            mockCompleteRegistration(
              const CompleteRegistrationParams(
                fullName: 'أحمد محمد',
                governorate: 'بغداد',
                district: 'الرصافة',
              ),
            ),
          );
        },
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'should emit failure when registration fails',
        build: () {
          when(mockCompleteRegistration(any)).thenAnswer(
            (_) async => const Left(ServerFailure(message: 'Server error')),
          );
          return bloc;
        },
        seed: () => tValidState,
        act: (bloc) => bloc.add(const RegistrationSubmitted()),
        expect:
            () => [
              tValidState.copyWith(
                formStatus: RegistrationFormStatus.submitting,
              ),
              tValidState.copyWith(
                formStatus: RegistrationFormStatus.failure,
                errorMessage: 'Server error',
              ),
            ],
      );

      blocTest<RegistrationBloc, RegistrationState>(
        'should not submit when form is invalid',
        build: () => bloc,
        seed:
            () => const RegistrationState(
              fullName: 'أحمد محمد',
              governorate: '',
              district: '',
              isValidName: true,
              isValidGovernorate: false,
              isValidDistrict: false,
              formStatus: RegistrationFormStatus.initial,
            ),
        act: (bloc) => bloc.add(const RegistrationSubmitted()),
        expect: () => [],
        verify: (_) {
          verifyNever(mockCompleteRegistration(any));
        },
      );
    });

    group('GovernorateData', () {
      test('should create from JSON correctly', () {
        final json = {
          'governorate': 'بغداد',
          'districts': ['الرصافة', 'الكرخ'],
        };

        final governorateData = GovernorateData.fromJson(json);

        expect(governorateData.governorate, 'بغداد');
        expect(governorateData.districts, ['الرصافة', 'الكرخ']);
      });

      test('should support equality', () {
        const governorate1 = GovernorateData(
          governorate: 'بغداد',
          districts: ['الرصافة', 'الكرخ'],
        );
        const governorate2 = GovernorateData(
          governorate: 'بغداد',
          districts: ['الرصافة', 'الكرخ'],
        );

        expect(governorate1, governorate2);
      });
    });

    group('availableDistricts', () {
      test('should return empty list when no governorate is selected', () {
        const state = RegistrationState();
        expect(state.availableDistricts, []);
      });

      test('should return districts for selected governorate', () {
        const governorates = [
          GovernorateData(
            governorate: 'بغداد',
            districts: ['الرصافة', 'الكرخ'],
          ),
          GovernorateData(
            governorate: 'البصرة',
            districts: ['البصرة', 'الزبير'],
          ),
        ];
        const state = RegistrationState(
          governorate: 'بغداد',
          governorates: governorates,
        );

        expect(state.availableDistricts, ['الرصافة', 'الكرخ']);
      });

      test('should return empty list when governorate not found', () {
        const governorates = [
          GovernorateData(
            governorate: 'بغداد',
            districts: ['الرصافة', 'الكرخ'],
          ),
        ];
        const state = RegistrationState(
          governorate: 'غير موجود',
          governorates: governorates,
        );

        expect(state.availableDistricts, []);
      });
    });
  });
}
