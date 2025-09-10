import '../../domain/entities/platform.dart';

class PlatformModel extends Platform {
  const PlatformModel({
    required super.id,
    required super.name,
    required super.logoUrl,
    required super.type,
    required super.description,
    super.isActive,
  });

  factory PlatformModel.fromJson(Map<String, dynamic> json) {
    return PlatformModel(
      id: json['id'] as String,
      name: json['name'] as String,
      logoUrl: json['logo_url'] as String,
      type: PlatformType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
      ),
      description: json['description'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'logo_url': logoUrl,
      'type': type.toString().split('.').last,
      'description': description,
      'is_active': isActive,
    };
  }

  factory PlatformModel.fromEntity(Platform platform) {
    return PlatformModel(
      id: platform.id,
      name: platform.name,
      logoUrl: platform.logoUrl,
      type: platform.type,
      description: platform.description,
      isActive: platform.isActive,
    );
  }
}
