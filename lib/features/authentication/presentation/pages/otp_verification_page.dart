import 'dart:async';

import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_header.dart';
import '../widgets/loading_overlay.dart';
import '../widgets/otp_input_field.dart';

class OtpVerificationPage extends StatefulWidget {
  final String phoneNumber;

  const OtpVerificationPage({super.key, required this.phoneNumber});

  @override
  State<OtpVerificationPage> createState() => _OtpVerificationPageState();
}

class _OtpVerificationPageState extends State<OtpVerificationPage> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = AppConstants.otpTimeoutSeconds;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _canResend = false;
    _remainingSeconds = AppConstants.otpTimeoutSeconds;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        setState(() {
          _canResend = true;
        });
        timer.cancel();
      }
    });
  }

  String get _formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_ios),
          ),
        ),
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is AuthAuthenticated) {
              AppRouter.goToHome(context);
            } else if (state is AuthOtpSent) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم إرسال رمز التحقق مرة أخرى'),
                  backgroundColor: AppColors.success,
                ),
              );
              _startTimer();
            }
          },
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state is AuthLoading,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Spacer(),

                      // Header
                      AuthHeader(
                        title: localizations.otpVerification,
                        subtitle:
                            '${localizations.otpSentTo}\n${Validators.formatIraqiPhoneNumber(widget.phoneNumber)}',
                      ),

                      const SizedBox(height: AppConstants.largePadding * 2),

                      // OTP input
                      Text(
                        localizations.enterOtp,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: AppConstants.defaultPadding),

                      OtpInputField(
                        controller: _otpController,
                        onCompleted: _verifyOtp,
                        onChanged: (value) {
                          if (value.length == AppConstants.otpLength) {
                            _verifyOtp(value);
                          }
                        },
                      ),

                      const SizedBox(height: AppConstants.largePadding),

                      // Timer and resend
                      if (!_canResend) ...[
                        Text(
                          'إعادة الإرسال خلال $_formattedTime',
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.grey600),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              localizations.didntReceiveOtp,
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.grey600),
                            ),
                            TextButton(
                              onPressed: _resendOtp,
                              child: Text(localizations.resendOtp),
                            ),
                          ],
                        ),
                      ],

                      const SizedBox(height: AppConstants.largePadding),

                      // Verify button
                      ElevatedButton(
                        onPressed:
                            _otpController.text.length == AppConstants.otpLength
                                ? () => _verifyOtp(_otpController.text)
                                : null,
                        child: Text(localizations.verify),
                      ),

                      const Spacer(flex: 2),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _verifyOtp(String otp) {
    if (Validators.isValidOtp(otp)) {
      context.read<AuthBloc>().add(
        AuthVerifyOtpRequested(phoneNumber: widget.phoneNumber, otp: otp),
      );
    }
  }

  void _resendOtp() {
    context.read<AuthBloc>().add(
      AuthSendOtpRequested(phoneNumber: widget.phoneNumber),
    );
  }
}
