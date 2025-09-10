import '../../domain/entities/product.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.price,
    required super.currency,
    super.originalPrice,
    super.rating,
    super.reviewCount,
    required super.platformId,
    required super.platformName,
    super.isInStock,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String,
      price: (json['price'] as num).toDouble(),
      currency: json['currency'] as String,
      originalPrice: json['original_price'] != null
          ? (json['original_price'] as num).toDouble()
          : null,
      rating: json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] as int?,
      platformId: json['platform_id'] as String,
      platformName: json['platform_name'] as String,
      isInStock: json['is_in_stock'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image_url': imageUrl,
      'price': price,
      'currency': currency,
      'original_price': originalPrice,
      'rating': rating,
      'review_count': reviewCount,
      'platform_id': platformId,
      'platform_name': platformName,
      'is_in_stock': isInStock,
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      imageUrl: product.imageUrl,
      price: product.price,
      currency: product.currency,
      originalPrice: product.originalPrice,
      rating: product.rating,
      reviewCount: product.reviewCount,
      platformId: product.platformId,
      platformName: product.platformName,
      isInStock: product.isInStock,
    );
  }
}
