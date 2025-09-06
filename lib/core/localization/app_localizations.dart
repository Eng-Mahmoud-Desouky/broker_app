import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = [
    Locale('ar', 'IQ'), // Arabic (Iraq)
    Locale('en', 'US'), // English (US)
  ];

  // Common
  String get appName => _localizedValues[locale.languageCode]!['app_name']!;
  String get ok => _localizedValues[locale.languageCode]!['ok']!;
  String get cancel => _localizedValues[locale.languageCode]!['cancel']!;
  String get retry => _localizedValues[locale.languageCode]!['retry']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get error => _localizedValues[locale.languageCode]!['error']!;
  String get success => _localizedValues[locale.languageCode]!['success']!;
  String get next => _localizedValues[locale.languageCode]!['next']!;
  String get back => _localizedValues[locale.languageCode]!['back']!;
  String get done => _localizedValues[locale.languageCode]!['done']!;

  // Navigation
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get favorites => _localizedValues[locale.languageCode]!['favorites']!;
  String get profile => _localizedValues[locale.languageCode]!['profile']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;

  // Authentication
  String get welcomeTitle => _localizedValues[locale.languageCode]!['welcome_title']!;
  String get welcomeSubtitle => _localizedValues[locale.languageCode]!['welcome_subtitle']!;
  String get phoneNumber => _localizedValues[locale.languageCode]!['phone_number']!;
  String get phoneNumberHint => _localizedValues[locale.languageCode]!['phone_number_hint']!;
  String get sendOtp => _localizedValues[locale.languageCode]!['send_otp']!;
  String get otpVerification => _localizedValues[locale.languageCode]!['otp_verification']!;
  String get otpSentTo => _localizedValues[locale.languageCode]!['otp_sent_to']!;
  String get enterOtp => _localizedValues[locale.languageCode]!['enter_otp']!;
  String get verify => _localizedValues[locale.languageCode]!['verify']!;
  String get resendOtp => _localizedValues[locale.languageCode]!['resend_otp']!;
  String get didntReceiveOtp => _localizedValues[locale.languageCode]!['didnt_receive_otp']!;

  // Errors
  String get invalidPhoneNumber => _localizedValues[locale.languageCode]!['invalid_phone_number']!;
  String get invalidOtp => _localizedValues[locale.languageCode]!['invalid_otp']!;
  String get otpExpired => _localizedValues[locale.languageCode]!['otp_expired']!;
  String get networkError => _localizedValues[locale.languageCode]!['network_error']!;
  String get serverError => _localizedValues[locale.languageCode]!['server_error']!;
  String get unknownError => _localizedValues[locale.languageCode]!['unknown_error']!;

  static const Map<String, Map<String, String>> _localizedValues = {
    'ar': {
      // Common
      'app_name': 'تطبيق الوسيط',
      'ok': 'موافق',
      'cancel': 'إلغاء',
      'retry': 'إعادة المحاولة',
      'loading': 'جاري التحميل...',
      'error': 'خطأ',
      'success': 'نجح',
      'next': 'التالي',
      'back': 'رجوع',
      'done': 'تم',

      // Navigation
      'home': 'الرئيسية',
      'favorites': 'المفضلة',
      'profile': 'الملف الشخصي',
      'settings': 'الإعدادات',

      // Authentication
      'welcome_title': 'مرحباً بك',
      'welcome_subtitle': 'أدخل رقم هاتفك للمتابعة',
      'phone_number': 'رقم الهاتف',
      'phone_number_hint': '7XX XXX XXXX',
      'send_otp': 'إرسال رمز التحقق',
      'otp_verification': 'التحقق من الرمز',
      'otp_sent_to': 'تم إرسال رمز التحقق إلى',
      'enter_otp': 'أدخل رمز التحقق',
      'verify': 'تحقق',
      'resend_otp': 'إعادة الإرسال',
      'didnt_receive_otp': 'لم تستلم الرمز؟',

      // Errors
      'invalid_phone_number': 'رقم الهاتف غير صحيح',
      'invalid_otp': 'رمز التحقق غير صحيح',
      'otp_expired': 'انتهت صلاحية رمز التحقق',
      'network_error': 'خطأ في الاتصال بالإنترنت',
      'server_error': 'خطأ في الخادم',
      'unknown_error': 'حدث خطأ غير متوقع',
    },
    'en': {
      // Common
      'app_name': 'Broker App',
      'ok': 'OK',
      'cancel': 'Cancel',
      'retry': 'Retry',
      'loading': 'Loading...',
      'error': 'Error',
      'success': 'Success',
      'next': 'Next',
      'back': 'Back',
      'done': 'Done',

      // Navigation
      'home': 'Home',
      'favorites': 'Favorites',
      'profile': 'Profile',
      'settings': 'Settings',

      // Authentication
      'welcome_title': 'Welcome',
      'welcome_subtitle': 'Enter your phone number to continue',
      'phone_number': 'Phone Number',
      'phone_number_hint': '7XX XXX XXXX',
      'send_otp': 'Send OTP',
      'otp_verification': 'OTP Verification',
      'otp_sent_to': 'OTP sent to',
      'enter_otp': 'Enter OTP',
      'verify': 'Verify',
      'resend_otp': 'Resend',
      'didnt_receive_otp': 'Didn\'t receive OTP?',

      // Errors
      'invalid_phone_number': 'Invalid phone number',
      'invalid_otp': 'Invalid OTP',
      'otp_expired': 'OTP expired',
      'network_error': 'Network error',
      'server_error': 'Server error',
      'unknown_error': 'An unexpected error occurred',
    },
  };
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return AppLocalizations.supportedLocales
        .any((supportedLocale) => supportedLocale.languageCode == locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
