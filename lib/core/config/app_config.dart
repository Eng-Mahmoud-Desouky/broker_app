/// Application configuration for different environments
class AppConfig {
  /// Whether the app is running in development mode
  static const bool isDevelopment = true; // Set to false for production
  
  /// Whether to bypass OTP verification in development mode
  static const bool bypassOtpInDevelopment = true;
  
  /// Whether to show debug information
  static const bool showDebugInfo = isDevelopment;
  
  /// Whether to enable verbose logging
  static const bool enableVerboseLogging = isDevelopment;
  
  /// Development phone numbers that can bypass OTP
  static const List<String> developmentPhoneNumbers = [
    '+9647700000000',
    '+9647800000000',
    '+9647900000000',
  ];
  
  /// Check if OTP should be bypassed for the given phone number
  static bool shouldBypassOtp(String phoneNumber) {
    if (!isDevelopment || !bypassOtpInDevelopment) {
      return false;
    }
    
    // In development mode, bypass OTP for all phone numbers
    // You can modify this logic to only allow specific numbers
    return true;
  }
  
  /// Get the environment name
  static String get environmentName {
    return isDevelopment ? 'Development' : 'Production';
  }
  
  /// Get the app version for development
  static String get appVersion {
    return isDevelopment ? '1.0.0-dev' : '1.0.0';
  }
}
