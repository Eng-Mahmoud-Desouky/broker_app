import 'package:equatable/equatable.dart';

/// Cart item entity representing a product added to cart from WebView
class CartItem extends Equatable {
  final String id;
  final String userId;
  final String productName;
  final double price;
  final String? imageUrl;
  final List<String>? images;
  final String productUrl;
  final String platform;
  final int quantity;
  final String? rating;
  final Map<String, dynamic>? metadata;
  final double?
  weightKg; // Weight in kilograms (nullable for backward compatibility)
  final Map<String, dynamic>?
  dimensions; // Product dimensions: {length, width, height, unit}
  final Map<String, dynamic>?
  rawSpecs; // Raw specification text: {weightText, dimensionText}
  final DateTime createdAt;
  final DateTime updatedAt;

  const CartItem({
    required this.id,
    required this.userId,
    required this.productName,
    required this.price,
    this.imageUrl,
    this.images,
    required this.productUrl,
    required this.platform,
    this.quantity = 1,
    this.rating,
    this.metadata,
    this.weightKg, // Weight is optional
    this.dimensions, // Dimensions are optional
    this.rawSpecs, // Raw specs are optional
    required this.createdAt,
    required this.updatedAt,
  });

  /// Get the primary image URL
  String get primaryImage =>
      imageUrl ?? (images?.isNotEmpty == true ? images!.first : '');

  /// Check if item has images
  bool get hasImages => primaryImage.isNotEmpty;

  /// Get platform display name
  String get platformDisplayName {
    switch (platform.toLowerCase()) {
      case 'amazon':
        return 'Amazon';
      case 'shein':
        return 'SHEIN';
      case 'aliexpress':
        return 'AliExpress';
      case 'taobao':
        return 'Taobao';
      case 'alibaba':
        return 'Alibaba';
      default:
        return platform;
    }
  }

  /// Get total price for this item
  double get totalPrice => price * quantity;

  /// Get total weight (weight * quantity) if weight is available
  double? get totalWeight {
    if (weightKg == null) return null;
    return weightKg! * quantity;
  }

  /// Check if weight is set
  bool get hasWeight => weightKg != null;

  /// Check if dimensions are set
  bool get hasDimensions => dimensions != null && dimensions!.isNotEmpty;

  /// Get formatted dimensions display (e.g., "30x20x10 cm")
  String get dimensionsDisplay {
    if (!hasDimensions) return '';
    try {
      final length = dimensions!['length'];
      final width = dimensions!['width'];
      final height = dimensions!['height'];
      final unit = dimensions!['unit'] ?? '';
      if (length != null && width != null && height != null) {
        return '$length×$width×$height $unit'.trim();
      }
    } catch (e) {
      // Ignore parsing errors
    }
    return '';
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    productName,
    price,
    imageUrl,
    images,
    productUrl,
    platform,
    quantity,
    rating,
    metadata,
    weightKg,
    dimensions,
    rawSpecs,
    createdAt,
    updatedAt,
  ];
}
