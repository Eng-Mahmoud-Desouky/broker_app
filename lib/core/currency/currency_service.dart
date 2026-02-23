import 'package:flutter/foundation.dart';

class CurrencyService {
  // Exchange rates
  static const double usdToIqdRate = 1300.0;
  static const double usdToEgpRate = 50.0;

  /// Converts an amount from a foreign currency to USD
  static double convertToUSD(double amount, String fromCurrency) {
    final currency = fromCurrency.toUpperCase().trim();

    if (currency == 'USD' || currency == '\$') {
      return amount;
    }

    double result;
    if (currency == 'IQD') {
      result = amount / usdToIqdRate;
    } else if (currency == 'EGP') {
      result = amount / usdToEgpRate;
    } else {
      // Default to USD if currency unknown
      if (kDebugMode) {
        print('⚠️ Unknown currency: $fromCurrency, assuming USD');
      }
      return amount;
    }

    if (kDebugMode) {
      print(
        '💱 Currency Conversion: $amount $fromCurrency -> \$${result.toStringAsFixed(2)}',
      );
    }

    return result;
  }

  /// Converts a USD amount to IQD
  static double convertUSDtoIQD(double usdAmount) {
    return usdAmount * usdToIqdRate;
  }

  /// Safely parses a price value from either num or String
  static double parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      // Remove symbols like $, IQD, etc. and whitespace
      final cleanValue = value.replaceAll(RegExp(r'[^\d.]'), '').trim();
      return double.tryParse(cleanValue) ?? 0.0;
    }
    return 0.0;
  }

  /// Safely converts any dynamic value to double
  static double toDouble(dynamic value, [double defaultValue = 0.0]) {
    if (value == null) return defaultValue;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? defaultValue;
    }
    return defaultValue;
  }

  /// Safely converts any dynamic value to double or null
  static double? toDoubleOrNull(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }
}
