import 'package:equatable/equatable.dart';

/// User address entity
class UserAddress extends Equatable {
  final String id;
  final String userId;
  final String name; // اسم العنوان مثل "المنزل" أو "العمل"
  final String fullName; // الاسم الكامل للمستلم
  final String phoneNumber;
  final String country;
  final String city;
  final String? stateProvince;
  final String streetAddress;
  final String? buildingNumber;
  final String? apartmentNumber;
  final String? postalCode;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserAddress({
    required this.id,
    required this.userId,
    required this.name,
    required this.fullName,
    required this.phoneNumber,
    required this.country,
    required this.city,
    this.stateProvince,
    required this.streetAddress,
    this.buildingNumber,
    this.apartmentNumber,
    this.postalCode,
    required this.isDefault,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get formatted address as single string
  String get formattedAddress {
    final parts = <String>[
      streetAddress,
      if (buildingNumber != null) 'بناية $buildingNumber',
      if (apartmentNumber != null) 'شقة $apartmentNumber',
      city,
      if (stateProvince != null) stateProvince!,
      country,
      if (postalCode != null) postalCode!,
    ];
    return parts.join(', ');
  }

  /// Convert to JSON for storage in orders table
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'country': country,
      'city': city,
      'state_province': stateProvince,
      'street_address': streetAddress,
      'building_number': buildingNumber,
      'apartment_number': apartmentNumber,
      'postal_code': postalCode,
    };
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    name,
    fullName,
    phoneNumber,
    country,
    city,
    stateProvince,
    streetAddress,
    buildingNumber,
    apartmentNumber,
    postalCode,
    isDefault,
    createdAt,
    updatedAt,
  ];
}
