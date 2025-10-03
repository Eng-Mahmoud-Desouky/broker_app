import '../../domain/entities/product.dart';

class ProductColorModel extends ProductColor {
  const ProductColorModel({
    required super.id,
    required super.productId,
    required super.colorHex,
    super.label,
  });

  factory ProductColorModel.fromMap(Map<String, dynamic> json) {
    return ProductColorModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      colorHex: json['color_hex'] ?? '',
      label: json['label'],
    );
  }

  factory ProductColorModel.fromJson(Map<String, dynamic> json) {
    return ProductColorModel(
      id: json['id'] ?? '',
      productId: json['product_id'] ?? '',
      colorHex: json['color_hex'] ?? '',
      label: json['label'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': productId,
      'color_hex': colorHex,
      'label': label,
    };
  }

  factory ProductColorModel.fromEntity(ProductColor color) {
    return ProductColorModel(
      id: color.id,
      productId: color.productId,
      colorHex: color.colorHex,
      label: color.label,
    );
  }
}
