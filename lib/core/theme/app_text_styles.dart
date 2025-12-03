import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  // Base text style with Cairo font
  static const TextStyle _baseTextStyle = TextStyle(
    fontFamily: 'Cairo',
    color: AppColors.onSurface,
  );

  // Display styles
  static TextStyle get displayLarge {
    return _baseTextStyle.copyWith(
      fontSize: 57,
      fontWeight: FontWeight.w400,
      letterSpacing: -0.25,
      height: 1.12,
    );
  }

  static TextStyle get displayMedium { 
    return _baseTextStyle.copyWith(
      fontSize: 45,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.16,
    );
  }

  static TextStyle get displaySmall {
    return _baseTextStyle.copyWith(
      fontSize: 36,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      height: 1.22,
    );
  }

  // Headline styles
  static TextStyle get headlineLarge {
    return _baseTextStyle.copyWith(
      fontSize: 32,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.25,
    );
  }

  static TextStyle get headlineMedium {
    return _baseTextStyle.copyWith(
      fontSize: 28,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.29,
    );
  }

  static TextStyle get headlineSmall {
    return _baseTextStyle.copyWith(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.33,
    );
  }

  // Title styles
  static TextStyle get titleLarge {
    return _baseTextStyle.copyWith(
      fontSize: 22,
      fontWeight: FontWeight.w600,
      letterSpacing: 0,
      height: 1.27,
    );
  }

  static TextStyle get titleMedium {
    return _baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.15,
      height: 1.50,
    );
  }

  static TextStyle get titleSmall {
    return _baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.43,
    );
  }

  // Label styles
  static TextStyle get labelLarge {
    return _baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
    );
  }

  static TextStyle get labelMedium {
    return _baseTextStyle.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.33,
    );
  }

  static TextStyle get labelSmall {
    return _baseTextStyle.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      height: 1.45,
    );
  }

  // Body styles
  static TextStyle get bodyLarge {
    return _baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.50,
    );
  }

  static TextStyle get bodyMedium {
    return _baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.25,
      height: 1.43,
    );
  }

  static TextStyle get bodySmall {
    return _baseTextStyle.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
    );
  }

  // Custom styles for specific use cases
  static TextStyle get button {
    return _baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.1,
      height: 1.25,
    );
  }

  static TextStyle get caption {
    return _baseTextStyle.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
      color: AppColors.onSurfaceVariant,
    );
  }

  static TextStyle get overline {
    return _baseTextStyle.copyWith(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      letterSpacing: 1.5,
      height: 1.6,
      color: AppColors.onSurfaceVariant,
    );
  }

  // Input field styles
  static TextStyle get inputText {
    return _baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.50,
    );
  }

  static TextStyle get inputLabel {
    return _baseTextStyle.copyWith(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.1,
      height: 1.43,
      color: AppColors.onSurfaceVariant,
    );
  }

  static TextStyle get inputHint {
    return _baseTextStyle.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.15,
      height: 1.50,
      color: AppColors.grey500,
    );
  }

  static TextStyle get inputError {
    return _baseTextStyle.copyWith(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      letterSpacing: 0.4,
      height: 1.33,
      color: AppColors.error,
    );
  }
}