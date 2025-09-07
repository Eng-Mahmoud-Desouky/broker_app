import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String phoneNumber;
  final String? email;
  final String? name;
  final String? profilePicture;
  final String? governorate;
  final String? district;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isVerified;

  const User({
    required this.id,
    required this.phoneNumber,
    this.email,
    this.name,
    this.profilePicture,
    this.governorate,
    this.district,
    required this.createdAt,
    this.updatedAt,
    required this.isVerified,
  });

  User copyWith({
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
    return User(
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

  @override
  List<Object?> get props => [
    id,
    phoneNumber,
    email,
    name,
    profilePicture,
    governorate,
    district,
    createdAt,
    updatedAt,
    isVerified,
  ];
}
