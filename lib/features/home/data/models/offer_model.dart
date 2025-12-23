import '../../domain/entities/offer.dart';

class OfferModel extends Offer {
  const OfferModel({
    required super.id,
    required super.title,
    required super.description,
    required super.imageUrl,
    super.discountPercentage,
    required super.validUntil,
    required super.actionUrl,
    super.isActive,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      discountPercentage: json['discount_percentage'] as String?,
      validUntil: DateTime.parse(json['valid_until'] as String),
      actionUrl: json['action_url'] as String,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'discount_percentage': discountPercentage,
      'valid_until': validUntil.toIso8601String(),
      'action_url': actionUrl,
      'is_active': isActive,
    };
  }

  factory OfferModel.fromEntity(Offer offer) {
    return OfferModel(
      id: offer.id,
      title: offer.title,
      description: offer.description,
      imageUrl: offer.imageUrl,
      discountPercentage: offer.discountPercentage,
      validUntil: offer.validUntil,
      actionUrl: offer.actionUrl,
      isActive: offer.isActive,
    );
  }
}
