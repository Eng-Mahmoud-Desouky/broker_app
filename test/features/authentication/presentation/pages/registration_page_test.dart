import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'package:broker_app/core/theme/app_theme.dart';
import 'package:broker_app/features/authentication/presentation/bloc/registration_bloc.dart';
import 'package:broker_app/features/authentication/presentation/pages/registration_page.dart';

import 'registration_page_test.mocks.dart';

@GenerateMocks([RegistrationBloc])
void main() {
  late MockRegistrationBloc mockRegistrationBloc;

  setUp(() {
    mockRegistrationBloc = MockRegistrationBloc();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      theme: AppTheme.lightTheme,
      home: BlocProvider<RegistrationBloc>.value(
        value: mockRegistrationBloc,
        child: const RegistrationPage(),
      ),
    );
  }

  const tGovernoratesData = [
    GovernorateData(
      governorate: 'بغداد',
      districts: ['الرصافة', 'الكرخ'],
    ),
    GovernorateData(
      governorate: 'البصرة',
      districts: ['البصرة', 'الزبير'],
    ),
  ];

  group('RegistrationPage', () {
    testWidgets('should display all required form fields', (tester) async {
      // arrange
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(governorates: tGovernoratesData),
      );
      when(mockRegistrationBloc.stream).thenAnswer(
        (_) => const Stream.empty(),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('إكمال التسجيل'), findsOneWidget);
      expect(find.text('الاسم الكامل'), findsOneWidget);
      expect(find.text('المحافظة'), findsOneWidget);
      expect(find.text('القضاء'), findsOneWidget);
      expect(find.text('إكمال التسجيل'), findsNWidgets(2)); // Title and button
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should trigger RegistrationNameChanged when name field changes', (tester) async {
      // arrange
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(governorates: tGovernoratesData),
      );
      when(mockRegistrationBloc.stream).thenAnswer(
        (_) => const Stream.empty(),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.enterText(find.byType(TextFormField), 'أحمد محمد');

      // assert
      verify(mockRegistrationBloc.add(const RegistrationNameChanged('أحمد محمد')));
    });

    testWidgets('should display name error when validation fails', (tester) async {
      // arrange
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(
          governorates: tGovernoratesData,
          nameError: 'الاسم الكامل مطلوب',
        ),
      );
      when(mockRegistrationBloc.stream).thenAnswer(
        (_) => const Stream.empty(),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.text('الاسم الكامل مطلوب'), findsOneWidget);
    });

    testWidgets('should populate governorate dropdown with data', (tester) async {
      // arrange
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(governorates: tGovernoratesData),
      );
      when(mockRegistrationBloc.stream).thenAnswer(
        (_) => const Stream.empty(),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();

      // assert
      expect(find.text('بغداد'), findsOneWidget);
      expect(find.text('البصرة'), findsOneWidget);
    });

    testWidgets('should trigger RegistrationGovernorateSelected when governorate is selected', (tester) async {
      // arrange
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(governorates: tGovernoratesData),
      );
      when(mockRegistrationBloc.stream).thenAnswer(
        (_) => const Stream.empty(),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byType(DropdownButtonFormField<String>).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('بغداد'));
      await tester.pumpAndSettle();

      // assert
      verify(mockRegistrationBloc.add(const RegistrationGovernorateSelected('بغداد')));
    });

    testWidgets('should enable district dropdown when governorate is selected', (tester) async {
      // arrange
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(
          governorates: tGovernoratesData,
          governorate: 'بغداد',
          isValidGovernorate: true,
        ),
      );
      when(mockRegistrationBloc.stream).thenAnswer(
        (_) => const Stream.empty(),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      final districtDropdown = find.byType(DropdownButtonFormField<String>).last;
      await tester.tap(districtDropdown);
      await tester.pumpAndSettle();

      // assert
      expect(find.text('الرصافة'), findsOneWidget);
      expect(find.text('الكرخ'), findsOneWidget);
    });

    testWidgets('should disable submit button when form is invalid', (tester) async {
      // arrange
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(
          governorates: tGovernoratesData,
          formStatus: RegistrationFormStatus.initial,
        ),
      );
      when(mockRegistrationBloc.stream).thenAnswer(
        (_) => const Stream.empty(),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      final submitButton = find.byType(ElevatedButton);

      // assert
      expect(tester.widget<ElevatedButton>(submitButton).onPressed, isNull);
    });

    testWidgets('should enable submit button when form is valid', (tester) async {
      // arrange
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(
          governorates: tGovernoratesData,
          formStatus: RegistrationFormStatus.valid,
        ),
      );
      when(mockRegistrationBloc.stream).thenAnswer(
        (_) => const Stream.empty(),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      final submitButton = find.byType(ElevatedButton);

      // assert
      expect(tester.widget<ElevatedButton>(submitButton).onPressed, isNotNull);
    });

    testWidgets('should trigger RegistrationSubmitted when submit button is pressed', (tester) async {
      // arrange
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(
          governorates: tGovernoratesData,
          formStatus: RegistrationFormStatus.valid,
        ),
      );
      when(mockRegistrationBloc.stream).thenAnswer(
        (_) => const Stream.empty(),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.tap(find.byType(ElevatedButton));

      // assert
      verify(mockRegistrationBloc.add(const RegistrationSubmitted()));
    });

    testWidgets('should show loading overlay when submitting', (tester) async {
      // arrange
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(
          governorates: tGovernoratesData,
          formStatus: RegistrationFormStatus.submitting,
        ),
      );
      when(mockRegistrationBloc.stream).thenAnswer(
        (_) => const Stream.empty(),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());

      // assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('should show success snackbar on successful registration', (tester) async {
      // arrange
      whenListen(
        mockRegistrationBloc,
        Stream.fromIterable([
          const RegistrationState(
            governorates: tGovernoratesData,
            formStatus: RegistrationFormStatus.submitting,
          ),
          const RegistrationState(
            governorates: tGovernoratesData,
            formStatus: RegistrationFormStatus.success,
          ),
        ]),
      );
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(governorates: tGovernoratesData),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.text('تم إكمال التسجيل بنجاح'), findsOneWidget);
    });

    testWidgets('should show error snackbar on registration failure', (tester) async {
      // arrange
      whenListen(
        mockRegistrationBloc,
        Stream.fromIterable([
          const RegistrationState(
            governorates: tGovernoratesData,
            formStatus: RegistrationFormStatus.submitting,
          ),
          const RegistrationState(
            governorates: tGovernoratesData,
            formStatus: RegistrationFormStatus.failure,
            errorMessage: 'فشل في التسجيل',
          ),
        ]),
      );
      when(mockRegistrationBloc.state).thenReturn(
        const RegistrationState(governorates: tGovernoratesData),
      );

      // act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      // assert
      expect(find.text('فشل في التسجيل'), findsOneWidget);
    });
  });
}
