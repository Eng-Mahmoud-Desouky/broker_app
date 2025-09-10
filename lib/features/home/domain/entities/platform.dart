import 'package:equatable/equatable.dart';

enum PlatformType { retail, wholesale }

class Platform extends Equatable {
  final String id;
  final String name;
  final String logoUrl;
  final PlatformType type;
  final String description;
  final bool isActive;

  const Platform({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.type,
    required this.description,
    this.isActive = true,
  });

  @override
  List<Object> get props => [
        id,
        name,
        logoUrl,
        type,
        description,
        isActive,
      ];
}
