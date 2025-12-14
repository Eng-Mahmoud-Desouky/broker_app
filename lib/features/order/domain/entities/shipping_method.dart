/// Shipping method enum
enum ShippingMethod {
  /// بحري - Sea shipping
  sea('بحري'),

  /// جوي - Air shipping
  air('جوي');

  final String arabicLabel;
  const ShippingMethod(this.arabicLabel);

  /// Get shipping method from database value
  static ShippingMethod fromString(String value) {
    switch (value) {
      case 'بحري':
        return ShippingMethod.sea;
      case 'جوي':
        return ShippingMethod.air;
      default:
        throw ArgumentError('Invalid shipping method: $value');
    }
  }

  /// Convert to database value
  String toDbValue() => arabicLabel;
}
