class Validators {
  // Phone number validation for Iraqi numbers
  static bool isValidIraqiPhoneNumber(String phoneNumber) {
    // Remove any spaces, dashes, or parentheses
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Remove country code if present
    if (cleanNumber.startsWith('+964')) {
      cleanNumber = cleanNumber.substring(4);
    } else if (cleanNumber.startsWith('964')) {
      cleanNumber = cleanNumber.substring(3);
    } else if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }

    // Iraqi mobile numbers start with 7 and are 10 digits long
    // Format: 7XXXXXXXXX (where X is any digit)
    return RegExp(r'^7[0-9]{9}$').hasMatch(cleanNumber);
  }

  // Format Iraqi phone number for display
  static String formatIraqiPhoneNumber(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Remove country code if present
    if (cleanNumber.startsWith('+964')) {
      cleanNumber = cleanNumber.substring(4);
    } else if (cleanNumber.startsWith('964')) {
      cleanNumber = cleanNumber.substring(3);
    } else if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }

    if (cleanNumber.length == 10 && cleanNumber.startsWith('7')) {
      // Format as: 7XX XXX XXXX
      return '${cleanNumber.substring(0, 3)} ${cleanNumber.substring(3, 6)} ${cleanNumber.substring(6)}';
    }

    return phoneNumber; // Return original if invalid
  }

  // Get full international format
  static String getInternationalFormat(String phoneNumber) {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Remove country code if present
    if (cleanNumber.startsWith('+964')) {
      return cleanNumber;
    } else if (cleanNumber.startsWith('964')) {
      return '+$cleanNumber';
    } else if (cleanNumber.startsWith('0')) {
      cleanNumber = cleanNumber.substring(1);
    }

    return '+964$cleanNumber';
  }

  // OTP validation
  static bool isValidOtp(String otp) {
    return RegExp(r'^[0-9]{6}$').hasMatch(otp);
  }

  // Email validation
  static bool isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email);
  }

  // Name validation (Arabic and English)
  static bool isValidName(String name) {
    final trimmedName = name.trim();

    // Check minimum length
    if (trimmedName.length < 2) {
      return false;
    }

    // Allow Arabic letters, English letters, and spaces
    // Arabic range: \u0600-\u06FF
    // English letters: a-zA-Z
    // Spaces: \s
    final regex = RegExp(r'^[\u0600-\u06FFa-zA-Z\s]+$');
    return regex.hasMatch(trimmedName);
  }
}
