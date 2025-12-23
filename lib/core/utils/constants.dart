class AppConstants {
  // App Info
  static const String appName = 'بروكر';
  static const String appVersion = '1.0.0';

  // Supabase
  static const String supabaseUrl = 'https://nthzmopgwaqfwcrhfgff.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im50aHptb3Bnd2FxZndjcmhmZ2ZmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcxMjg2OTcsImV4cCI6MjA3MjcwNDY5N30.OvgYUrUl0dR5ZBOBzavOioMivt0iXXe0KpcZ7by-2pk';
  static const String fcmTokensTable = 'user_fcm_tokens';

  // Storage Keys
  static const String userTokenKey = 'user_token';
  static const String userDataKey = 'user_data';
  static const String isFirstTimeKey = 'is_first_time';
  static const String languageKey = 'language';

  // Phone Number
  static const String iraqCountryCode = '+964';
  static const String iraqCountryIsoCode = 'IQ';

  // OTP
  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 120; // 2 minutes

  // API Timeouts
  static const int connectionTimeout = 30000; // 30 seconds
  static const int receiveTimeout = 30000; // 30 seconds

  // Validation
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 11;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;
}
