import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/platform.dart';
import '../../domain/entities/product.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeLocalDataSource localDataSource;

  HomeRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Offer>>> getFeaturedOffers() async {
    try {
      final offers = await localDataSource.getFeaturedOffers();
      return Right(offers);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get featured offers: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Platform>>> getPlatforms() async {
    try {
      final platforms = await localDataSource.getPlatforms();
      return Right(platforms);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get platforms: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Platform>>> getPlatformsByType(String type) async {
    try {
      final platforms = await localDataSource.getPlatformsByType(type);
      return Right(platforms);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get platforms by type: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getSuggestedProducts() async {
    try {
      final products = await localDataSource.getSuggestedProducts();
      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get suggested products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    try {
      final products = await localDataSource.searchProducts(query);
      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search products: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProductsByImage(String imagePath) async {
    // Placeholder implementation for image search
    try {
      // For now, return suggested products as placeholder
      final products = await localDataSource.getSuggestedProducts();
      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to search products by image: ${e.toString()}'));
    }
  }
}
