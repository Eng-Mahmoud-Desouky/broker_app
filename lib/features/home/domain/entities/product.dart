import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final double price;
  final String currency;
  final double? originalPrice;
  final double? rating;
  final int? reviewCount;
  final String platformId;
  final String platformName;
  final bool isInStock;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.price,
    required this.currency,
    this.originalPrice,
    this.rating,
    this.reviewCount,
    required this.platformId,
    required this.platformName,
    this.isInStock = true,
  });

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double? get discountPercentage {
    if (!hasDiscount) return null;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        imageUrl,
        price,
        currency,
        originalPrice,
        rating,
        reviewCount,
        platformId,
        platformName,
        isInStock,
      ];
}
