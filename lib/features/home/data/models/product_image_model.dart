import '../../domain/entities/product.dart';

class ProductImageModel extends ProductImage {
  const ProductImageModel({
    required super.id,
    required super.productId,
    required super.imageUrl,
    required super.position,
  });

  factory ProductImageModel.fromMap(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      position: json['position'] ?? 0,
    );
  }

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      position: json['position'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'image_url': imageUrl,
      'position': position,
    };
  }

  factory ProductImageModel.fromEntity(ProductImage image) {
    return ProductImageModel(
      id: image.id,
      productId: image.productId,
      imageUrl: image.imageUrl,
      position: image.position,
    );
  }
}
