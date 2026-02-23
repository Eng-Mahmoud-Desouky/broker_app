import '../../../../core/currency/currency_service.dart';
import '../../domain/entities/cart_item.dart';

/// Cart item model for data layer
class CartItemModel extends CartItem {
  const CartItemModel({
    required super.id,
    required super.userId,
    required super.productName,
    required super.price,
    super.imageUrl,
    super.images,
    required super.productUrl,
    required super.platform,
    super.quantity,
    super.rating,
    super.metadata,
    super.weightKg,
    super.dimensions,
    super.rawSpecs,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create from Supabase JSON
  factory CartItemModel.fromJson(Map<String, dynamic> json) {
    return CartItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      productName: json['product_name'] as String,
      price: CurrencyService.parsePrice(json['price']),
      imageUrl: json['image_url'] as String?,
      images:
          json['images'] != null
              ? List<String>.from(json['images'] as List)
              : null,
      productUrl: json['product_url'] as String,
      platform: json['platform'] as String,
      quantity: json['quantity'] as int? ?? 1,
      rating: json['rating'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      weightKg: CurrencyService.toDouble(json['weight_kg'], 0.0),
      dimensions: json['dimensions'] as Map<String, dynamic>?,
      rawSpecs: json['raw_specs'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON for Supabase
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'product_name': productName,
      'price': price,
      'image_url': imageUrl,
      'images': images,
      'product_url': productUrl,
      'platform': platform,
      'quantity': quantity,
      'rating': rating,
      'metadata': metadata,
      'weight_kg': weightKg,
      'dimensions': dimensions,
      'raw_specs': rawSpecs,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to insert JSON (without id, created_at, updated_at)
  Map<String, dynamic> toInsertJson() {
    return {
      'user_id': userId,
      'product_name': productName,
      'price': price,
      'image_url': imageUrl,
      'images': images,
      'product_url': productUrl,
      'platform': platform,
      'quantity': quantity,
      'rating': rating,
      'metadata': metadata,
      'weight_kg': weightKg,
      'dimensions': dimensions,
      'raw_specs': rawSpecs,
    };
  }

  /// Create from entity
  factory CartItemModel.fromEntity(CartItem item) {
    return CartItemModel(
      id: item.id,
      userId: item.userId,
      productName: item.productName,
      price: item.price,
      imageUrl: item.imageUrl,
      images: item.images,
      productUrl: item.productUrl,
      platform: item.platform,
      quantity: item.quantity,
      rating: item.rating,
      metadata: item.metadata,
      weightKg: item.weightKg,
      dimensions: item.dimensions,
      rawSpecs: item.rawSpecs,
      createdAt: item.createdAt,
      updatedAt: item.updatedAt,
    );
  }

  /// Copy with method
  CartItemModel copyWith({
    String? id,
    String? userId,
    String? productName,
    double? price,
    String? imageUrl,
    List<String>? images,
    String? productUrl,
    String? platform,
    int? quantity,
    String? rating,
    Map<String, dynamic>? metadata,
    double? weightKg,
    Map<String, dynamic>? dimensions,
    Map<String, dynamic>? rawSpecs,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CartItemModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      productName: productName ?? this.productName,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      images: images ?? this.images,
      productUrl: productUrl ?? this.productUrl,
      platform: platform ?? this.platform,
      quantity: quantity ?? this.quantity,
      rating: rating ?? this.rating,
      metadata: metadata ?? this.metadata,
      weightKg: weightKg ?? this.weightKg,
      dimensions: dimensions ?? this.dimensions,
      rawSpecs: rawSpecs ?? this.rawSpecs,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
