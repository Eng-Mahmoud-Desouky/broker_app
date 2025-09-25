import '../../domain/entities/product.dart';
import 'product_image_model.dart';
import 'product_color_model.dart';

class ProductModel extends Product {
  const ProductModel({
    required super.id,
    required super.name,
    required super.description,
    required super.mainImageUrl,
    required super.price,
    required super.currency,
    super.originalPrice,
    super.rating,
    super.reviewCount,
    required super.platformId,
    required super.platformName,
    super.categoryId,
    super.categoryName,
    super.isInStock,
    super.minOrder,
    super.specifications,
    super.createdAt,
    super.images,
    super.colors,
  });

  factory ProductModel.fromMap(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      mainImageUrl: json['main_image_url'] ?? '',
      price: (json['price'] ?? 0 as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      originalPrice:
          json['original_price'] != null
              ? (json['original_price'] as num).toDouble()
              : null,
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] ?? 0 as int?,
      platformId: json['platform_id'] ?? '',
      platformName: json['platform_name'] ?? '',
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      isInStock: json['is_in_stock'] as bool? ?? true,
      minOrder: json['min_order'] as int? ?? 1,
      specifications: json['specifications'] as Map<String, dynamic>?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      images:
          json['product_images'] != null
              ? (json['product_images'] as List<dynamic>)
                  .map(
                    (img) =>
                        ProductImageModel.fromMap(img as Map<String, dynamic>),
                  )
                  .toList()
              : json['images'] != null
              ? (json['images'] as List<dynamic>)
                  .map(
                    (img) =>
                        ProductImageModel.fromMap(img as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      colors:
          json['product_colors'] != null
              ? (json['product_colors'] as List<dynamic>)
                  .map(
                    (color) => ProductColorModel.fromMap(
                      color as Map<String, dynamic>,
                    ),
                  )
                  .toList()
              : json['colors'] != null
              ? (json['colors'] as List<dynamic>)
                  .map(
                    (color) => ProductColorModel.fromMap(
                      color as Map<String, dynamic>,
                    ),
                  )
                  .toList()
              : null,
    );
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      mainImageUrl: json['main_image_url'] ?? '',
      price: (json['price'] ?? 0 as num).toDouble(),
      currency: json['currency'] ?? 'USD',
      originalPrice:
          json['original_price'] != null
              ? (json['original_price'] as num).toDouble()
              : null,
      rating:
          json['rating'] != null ? (json['rating'] as num).toDouble() : null,
      reviewCount: json['review_count'] ?? 0 as int?,
      platformId: json['platform_id'] ?? '',
      platformName: json['platform_name'] ?? '',
      categoryId: json['category_id'] as String?,
      categoryName: json['category_name'] as String?,
      isInStock: json['is_in_stock'] as bool? ?? true,
      minOrder: json['min_order'] ?? 1,
      specifications: json['specifications'] as Map<String, dynamic>?,
      createdAt:
          json['created_at'] != null
              ? DateTime.parse(json['created_at'] as String)
              : null,
      images:
          json['images'] != null
              ? (json['images'] as List<dynamic>)
                  .map(
                    (img) =>
                        ProductImageModel.fromJson(img as Map<String, dynamic>),
                  )
                  .toList()
              : null,
      colors:
          json['colors'] != null
              ? (json['colors'] as List<dynamic>)
                  .map(
                    (color) => ProductColorModel.fromJson(
                      color as Map<String, dynamic>,
                    ),
                  )
                  .toList()
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'main_image_url': mainImageUrl,
      'price': price,
      'currency': currency,
      'original_price': originalPrice,
      'rating': rating,
      'review_count': reviewCount,
      'platform_id': platformId,
      'platform_name': platformName,
      'category_id': categoryId,
      'category_name': categoryName,
      'is_in_stock': isInStock,
      'min_order': minOrder,
      'specifications': specifications,
      'created_at': createdAt?.toIso8601String(),
      'images':
          images
              ?.map((img) => ProductImageModel.fromEntity(img).toJson())
              .toList(),
      'colors':
          colors
              ?.map((color) => ProductColorModel.fromEntity(color).toJson())
              .toList(),
    };
  }

  factory ProductModel.fromEntity(Product product) {
    return ProductModel(
      id: product.id,
      name: product.name,
      description: product.description,
      mainImageUrl: product.mainImageUrl,
      price: product.price,
      currency: product.currency,
      originalPrice: product.originalPrice,
      rating: product.rating,
      reviewCount: product.reviewCount,
      platformId: product.platformId,
      platformName: product.platformName,
      categoryId: product.categoryId,
      categoryName: product.categoryName,
      isInStock: product.isInStock,
      minOrder: product.minOrder,
      specifications: product.specifications,
      createdAt: product.createdAt,
      images: product.images,
      colors: product.colors,
    );
  }
}
