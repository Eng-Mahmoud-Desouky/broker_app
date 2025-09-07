import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.phoneNumber,
    super.email,
    super.name,
    super.profilePicture,
    super.governorate,
    super.district,
    required super.createdAt,
    super.updatedAt,
    required super.isVerified,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      phoneNumber: json['phone'] as String,
      email: json['email'] as String?,
      name: json['user_metadata']?['name'] as String?,
      profilePicture: json['user_metadata']?['profile_picture'] as String?,
      governorate: json['user_metadata']?['governorate'] as String?,
      district: json['user_metadata']?['district'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] != null
              ? DateTime.parse(json['updated_at'] as String)
              : null,
      isVerified: json['phone_confirmed_at'] != null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phone': phoneNumber,
      'email': email,
      'user_metadata': {
        'name': name,
        'profile_picture': profilePicture,
        'governorate': governorate,
        'district': district,
      },
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'phone_confirmed_at': isVerified ? createdAt.toIso8601String() : null,
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      phoneNumber: user.phoneNumber,
      email: user.email,
      name: user.name,
      profilePicture: user.profilePicture,
      governorate: user.governorate,
      district: user.district,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      isVerified: user.isVerified,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? phoneNumber,
    String? email,
    String? name,
    String? profilePicture,
    String? governorate,
    String? district,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
  }) {
    return UserModel(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      name: name ?? this.name,
      profilePicture: profilePicture ?? this.profilePicture,
      governorate: governorate ?? this.governorate,
      district: district ?? this.district,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
    );
  }
}
