import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/offer.dart';
import '../entities/platform.dart';
import '../entities/product.dart';
import '../entities/category.dart';

abstract class HomeRepository {
  /// Get featured offers for the banner slider
  Future<Either<Failure, List<Offer>>> getFeaturedOffers();

  /// Get all available platforms
  Future<Either<Failure, List<Platform>>> getPlatforms();

  /// Get platforms by type (retail or wholesale)
  Future<Either<Failure, List<Platform>>> getPlatformsByType(String type);

  /// Get suggested products for the home page
  Future<Either<Failure, List<Product>>> getSuggestedProducts();

  /// Get all products from the data source
  Future<Either<Failure, List<Product>>> getProducts();

  /// Get a specific product by its ID
  Future<Either<Failure, Product>> getProductById(String id);

  /// Search products by text query
  Future<Either<Failure, List<Product>>> searchProducts(String query);

  /// Search products by image (placeholder for future implementation)
  Future<Either<Failure, List<Product>>> searchProductsByImage(
    String imagePath,
  );

  /// Get all categories
  Future<Either<Failure, List<Category>>> getCategories();

  /// Get products by category
  Future<Either<Failure, List<Product>>> getProductsByCategory(
    String categoryId,
  );

  /// Get similar products for a given product
  Future<Either<Failure, List<Product>>> getSimilarProducts(String productId);
}
