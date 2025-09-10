import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/offer.dart';
import '../entities/platform.dart';
import '../entities/product.dart';

abstract class HomeRepository {
  /// Get featured offers for the banner slider
  Future<Either<Failure, List<Offer>>> getFeaturedOffers();

  /// Get all available platforms
  Future<Either<Failure, List<Platform>>> getPlatforms();

  /// Get platforms by type (retail or wholesale)
  Future<Either<Failure, List<Platform>>> getPlatformsByType(String type);

  /// Get suggested products for the home page
  Future<Either<Failure, List<Product>>> getSuggestedProducts();

  /// Search products by text query
  Future<Either<Failure, List<Product>>> searchProducts(String query);

  /// Search products by image (placeholder for future implementation)
  Future<Either<Failure, List<Product>>> searchProductsByImage(String imagePath);
}
