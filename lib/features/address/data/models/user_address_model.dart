import '../../domain/entities/user_address.dart';

/// User address model for data layer
class UserAddressModel extends UserAddress {
  const UserAddressModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.fullName,
    required super.phoneNumber,
    required super.country,
    required super.city,
    super.stateProvince,
    required super.streetAddress,
    super.buildingNumber,
    super.apartmentNumber,
    super.postalCode,
    required super.isDefault,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Supabase JSON
  factory UserAddressModel.fromJson(Map<String, dynamic> json) {
    return UserAddressModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      country: json['country'] as String,
      city: json['city'] as String,
      stateProvince: json['state_province'] as String?,
      streetAddress: json['street_address'] as String,
      buildingNumber: json['building_number'] as String?,
      apartmentNumber: json['apartment_number'] as String?,
      postalCode: json['postal_code'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase insert
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
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
      'is_default': isDefault,
    };
  }

  /// Convert to JSON for Supabase update
  Map<String, dynamic> toUpdateJson() {
    return {
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
      'is_default': isDefault,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Convert to JSON (for general use)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
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
      'is_default': isDefault,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Create from entity
  factory UserAddressModel.fromEntity(UserAddress address) {
    return UserAddressModel(
      id: address.id,
      userId: address.userId,
      name: address.name,
      fullName: address.fullName,
      phoneNumber: address.phoneNumber,
      country: address.country,
      city: address.city,
      stateProvince: address.stateProvince,
      streetAddress: address.streetAddress,
      buildingNumber: address.buildingNumber,
      apartmentNumber: address.apartmentNumber,
      postalCode: address.postalCode,
      isDefault: address.isDefault,
      createdAt: address.createdAt,
      updatedAt: address.updatedAt,
    );
  }
}
