import 'package:equatable/equatable.dart';

class Offer extends Equatable {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String? discountPercentage;
  final DateTime validUntil;
  final String actionUrl;

  const Offer({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.discountPercentage,
    required this.validUntil,
    required this.actionUrl,
  });

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        discountPercentage,
        validUntil,
        actionUrl,
      ];
}
