import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/constants.dart';
import '../../../../core/utils/validators.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_header.dart';
import '../widgets/loading_overlay.dart';

class PhoneInputPage extends StatefulWidget {
  const PhoneInputPage({super.key});

  @override
  State<PhoneInputPage> createState() => _PhoneInputPageState();
}

class _PhoneInputPageState extends State<PhoneInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  String _completePhoneNumber = '';
  bool _isValidPhone = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (context) => sl<AuthBloc>(),
      child: Scaffold(
        body: BlocConsumer<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            } else if (state is AuthOtpSent) {
              AppRouter.goToOtpVerification(context, state.phoneNumber);
            } else if (state is AuthAuthenticated) {
              // Handle bypass authentication success
              final user = state.session.user;
              if (user.name == null ||
                  user.governorate == null ||
                  user.district == null) {
                AppRouter.goToRegistration(context);
              } else {
                AppRouter.goToHome(context);
              }
            }
          },
          builder: (context, state) {
            return LoadingOverlay(
              isLoading: state is AuthLoading,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Spacer(),

                        // Development mode indicator
                        if (AppConfig.isDevelopment &&
                            AppConfig.bypassOtpInDevelopment)
                          Container(
                            margin: const EdgeInsets.only(
                              bottom: AppConstants.defaultPadding,
                            ),
                            padding: const EdgeInsets.all(
                              AppConstants.smallPadding,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warning.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                AppConstants.defaultBorderRadius,
                              ),
                              border: Border.all(color: AppColors.warning),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.developer_mode,
                                  color: AppColors.warning,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: AppConstants.smallPadding,
                                ),
                                Expanded(
                                  child: Text(
                                    'وضع التطوير: تم تعطيل التحقق من OTP',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall?.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Header
                        AuthHeader(
                          title: localizations.welcomeTitle,
                          subtitle: localizations.welcomeSubtitle,
                        ),

                        const SizedBox(height: AppConstants.largePadding * 2),

                        // Phone input field
                        IntlPhoneField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: localizations.phoneNumber,
                            hintText: localizations.phoneNumberHint,
                            prefixIcon: const Icon(Icons.phone_outlined),
                          ),
                          initialCountryCode: AppConstants.iraqCountryIsoCode,
                          // countries: const ['IQ'], // Only Iraq - commented out due to type issue
                          showCountryFlag: true,
                          showDropdownIcon: false,
                          disableLengthCheck: true,
                          textAlign: TextAlign.right,
                          style: Theme.of(context).textTheme.bodyLarge,
                          onChanged: (phone) {
                            setState(() {
                              _completePhoneNumber = phone.completeNumber;
                              _isValidPhone =
                                  Validators.isValidIraqiPhoneNumber(
                                    phone.number,
                                  );
                            });
                          },
                          validator: (phone) {
                            if (phone == null || phone.number.isEmpty) {
                              return localizations.invalidPhoneNumber;
                            }
                            if (!Validators.isValidIraqiPhoneNumber(
                              phone.number,
                            )) {
                              return localizations.invalidPhoneNumber;
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: AppConstants.largePadding),

                        // Send OTP button
                        ElevatedButton(
                          onPressed: _isValidPhone ? _sendOtp : null,
                          child: Text(localizations.sendOtp),
                        ),

                        const Spacer(flex: 2),

                        // Terms and conditions
                        Text(
                          'بالمتابعة، أنت توافق على شروط الاستخدام وسياسة الخصوصية',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: AppColors.grey600),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      // Check if we should bypass OTP in development mode
      if (AppConfig.shouldBypassOtp(_completePhoneNumber)) {
        // Bypass OTP verification for development
        context.read<AuthBloc>().add(
          AuthBypassOtpRequested(phoneNumber: _completePhoneNumber),
        );
      } else {
        // Normal OTP flow
        context.read<AuthBloc>().add(
          AuthSendOtpRequested(phoneNumber: _completePhoneNumber),
        );
      }
    }
  }
}
