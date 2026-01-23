import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/auth_session.dart';

import '../../domain/usecases/bypass_otp_verification.dart';
import '../../domain/usecases/get_current_session.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../../../core/services/notifications_service.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final SendOtp sendOtp;
  final VerifyOtp verifyOtp;
  final BypassOtpVerification bypassOtpVerification;
  final GetCurrentSession getCurrentSession;
  final SignOut signOut;
  final NotificationsService notificationsService;

  AuthBloc({
    required this.sendOtp,
    required this.verifyOtp,
    required this.bypassOtpVerification,
    required this.getCurrentSession,
    required this.signOut,
    required this.notificationsService,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSendOtpRequested>(_onAuthSendOtpRequested);
    on<AuthVerifyOtpRequested>(_onAuthVerifyOtpRequested);
    on<AuthBypassOtpRequested>(_onAuthBypassOtpRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await getCurrentSession(NoParams());

    result.fold((failure) => emit(AuthUnauthenticated()), (session) {
      if (session != null && !session.isExpired) {
        notificationsService.registerToken();

        final user = session.user;
        if (user.name != null &&
            user.governorate != null &&
            user.district != null) {
          emit(AuthAuthenticatedWithProfile(session: session));
        } else {
          emit(AuthAuthenticatedWithoutProfile(session: session));
        }
      } else {
        emit(AuthUnauthenticated());
      }
    });
  }

  Future<void> _onAuthSendOtpRequested(
    AuthSendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthLoading());

      print('\n🔄 AuthBloc:Processing AuthSendOtpRequested');
      final result = await sendOtp(
        SendOtpParams(phoneNumber: event.phoneNumber),
      );

      result.fold(
        (failure) {
          print('❌ AuthBloc: SendOtp failed: ${failure.message}');
          emit(AuthError(message: failure.message));
        },
        (_) {
          print('✅ AuthBloc: SendOtp success, emitting AuthOtpSent');
          emit(AuthOtpSent(phoneNumber: event.phoneNumber));
        },
      );
    } catch (e, stackTrace) {
      print('❌ CRITICAL ERROR in AuthBloc: $e');
      print('Stack trace: $stackTrace');
      emit(AuthError(message: 'حدث خطأ غير متوقع: $e'));
    }
  }

  Future<void> _onAuthVerifyOtpRequested(
    AuthVerifyOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await verifyOtp(
      VerifyOtpParams(phoneNumber: event.phoneNumber, otp: event.otp),
    );

    result.fold((failure) => emit(AuthError(message: failure.message)), (
      session,
    ) {
      notificationsService.registerToken();

      final user = session.user;
      if (user.name != null &&
          user.governorate != null &&
          user.district != null) {
        emit(AuthAuthenticatedWithProfile(session: session));
      } else {
        emit(AuthAuthenticatedWithoutProfile(session: session));
      }
    });
  }

  Future<void> _onAuthBypassOtpRequested(
    AuthBypassOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await bypassOtpVerification(
      BypassOtpParams(phoneNumber: event.phoneNumber),
    );

    result.fold((failure) => emit(AuthError(message: failure.message)), (
      session,
    ) {
      notificationsService.registerToken();

      final user = session.user;
      if (user.name != null &&
          user.governorate != null &&
          user.district != null) {
        emit(AuthAuthenticatedWithProfile(session: session));
      } else {
        emit(AuthAuthenticatedWithoutProfile(session: session));
      }
    });
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    final result = await signOut(NoParams());

    result.fold((failure) => emit(AuthError(message: failure.message)), (_) {
      notificationsService.deleteToken();
      emit(AuthUnauthenticated());
    });
  }
}
