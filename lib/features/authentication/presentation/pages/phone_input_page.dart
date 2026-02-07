import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

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

    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          print('👂 PhoneInputPage Listener received state: $state');

          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          } else if (state is AuthOtpSent) {
            print(
              '🚀 Navigation to OTP Verification Page for ${state.phoneNumber}',
            );
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
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            MediaQuery.of(context).size.height -
                            MediaQuery.of(context).padding.top -
                            MediaQuery.of(context).padding.bottom -
                            (AppConstants.defaultPadding * 2),
                      ),
                      child: IntrinsicHeight(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(
                              height: AppConstants.largePadding * 2,
                            ),

                            // Header
                            AuthHeader(
                              title: localizations.welcomeTitle,
                              subtitle: localizations.welcomeSubtitle,
                            ),

                            const SizedBox(
                              height: AppConstants.largePadding * 2,
                            ),

                            // Phone input field
                            IntlPhoneField(
                              controller: _phoneController,
                              decoration: InputDecoration(
                                labelText: localizations.phoneNumber,
                                hintText: localizations.phoneNumberHint,
                                prefixIcon: const Icon(Icons.phone_outlined),
                              ),
                              initialCountryCode: 'IQ',
                              countries: [
                                countries.firstWhere(
                                  (country) => country.code == 'IQ',
                                ),
                              ],
                              showCountryFlag: true,
                              showDropdownIcon: false,
                              flagsButtonPadding: EdgeInsets.zero,
                              flagsButtonMargin: EdgeInsets.zero,
                              disableLengthCheck: true,
                              textAlign: TextAlign.left,
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

                            const SizedBox(height: AppConstants.defaultPadding),

                            // Terms and conditions
                            Text(
                              'بالمتابعة، أنت توافق على شروط الاستخدام وسياسة الخصوصية',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: AppColors.grey600),
                              textAlign: TextAlign.center,
                            ),

                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _sendOtp() {
    if (_formKey.currentState!.validate()) {
      // Ensure we have a valid phone number
      if (_completePhoneNumber.isEmpty) {
        print('❌ Phone number is empty');
        return;
      }

      // Debug logging
      print('\n📱 ===== SENDING OTP =====');
      print('📱 Phone number: $_completePhoneNumber');
      print('📱 Phone length: ${_completePhoneNumber.length}');

      print('========================\n');

      // Normal OTP flow
      context.read<AuthBloc>().add(
        AuthSendOtpRequested(phoneNumber: _completePhoneNumber),
      );
    } else {
      print('❌ Form validation failed');
    }
  }
}
