import 'package:equatable/equatable.dart';

// Product Image Entity
class ProductImage extends Equatable {
  final String id;
  final String productId;
  final String imageUrl;
  final int position;

  const ProductImage({
    required this.id,
    required this.productId,
    required this.imageUrl,
    required this.position,
  });

  @override
  List<Object> get props => [id, productId, imageUrl, position];
}

// Product Color Entity
class ProductColor extends Equatable {
  final String id;
  final String productId;
  final String colorHex;
  final String? label;

  const ProductColor({
    required this.id,
    required this.productId,
    required this.colorHex,
    this.label,
  });

  @override
  List<Object?> get props => [id, productId, colorHex, label];
}

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final String mainImageUrl;
  final double price;
  final double? originalPrice;
  final double? rating;
  final int? reviewCount;
  final String platformId;
  final String platformName;
  final String? categoryId;
  final String? categoryName;
  final bool isInStock;
  final int minOrder;
  final Map<String, dynamic>? specifications;
  final DateTime? createdAt;
  final List<ProductImage>? images;
  final List<ProductColor>? colors;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.mainImageUrl,
    required this.price,
    this.originalPrice,
    this.rating,
    this.reviewCount,
    required this.platformId,
    required this.platformName,
    this.categoryId,
    this.categoryName,
    this.isInStock = true,
    this.minOrder = 1,
    this.specifications,
    this.createdAt,
    this.images,
    this.colors,
  });

  // Legacy getter for backward compatibility
  String get imageUrl => mainImageUrl;

  bool get hasDiscount => originalPrice != null && originalPrice! > price;

  double? get discountPercentage {
    if (!hasDiscount) return null;
    return ((originalPrice! - price) / originalPrice!) * 100;
  }

  String get formattedPrice {
    return '\$${price.toStringAsFixed(2)}';
  }

  String? get formattedOriginalPrice {
    if (originalPrice == null) return null;
    return '\$${originalPrice!.toStringAsFixed(2)}';
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    mainImageUrl,
    price,
    originalPrice,
    rating,
    reviewCount,
    platformId,
    platformName,
    categoryId,
    categoryName,
    isInStock,
    minOrder,
    specifications,
    createdAt,
    images,
    colors,
  ];
}
