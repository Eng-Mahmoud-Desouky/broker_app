import 'dart:developer';

import 'package:dartz/dartz.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/platform.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/home_repository.dart';
import '../datasources/home_local_data_source.dart';
import '../datasources/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource remoteDataSource;
  final HomeLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  HomeRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Offer>>> getFeaturedOffers() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOffers = await remoteDataSource.getOffers();

        // If Supabase returns empty results, fall back to local data for demo purposes
        if (remoteOffers.isEmpty) {
          final localOffers = await localDataSource.getFeaturedOffers();
          return Right(localOffers);
        }

        return Right(remoteOffers);
      } on ServerException catch (e) {
        // If remote fails, try local fallback
        try {
          final localOffers = await localDataSource.getFeaturedOffers();
          return Right(localOffers);
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        // If remote fails, try local fallback
        try {
          final localOffers = await localDataSource.getFeaturedOffers();
          return Right(localOffers);
        } on CacheException {
          return Left(ServerFailure(message: 'Remote failed: $e'));
        }
      }
    } else {
      // No internet connection, use local data
      try {
        final localOffers = await localDataSource.getFeaturedOffers();
        return Right(localOffers);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(
          CacheFailure(message: 'Failed to get cached offers: ${e.toString()}'),
        );
      }
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
      return Left(
        ServerFailure(message: 'Failed to get platforms: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Either<Failure, List<Platform>>> getPlatformsByType(
    String type,
  ) async {
    try {
      final platforms = await localDataSource.getPlatformsByType(type);
      return Right(platforms);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to get platforms by type: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getSuggestedProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getSuggestedProducts();

        // If Supabase returns empty results, fall back to local data for demo purposes
        if (remoteProducts.isEmpty) {
          final localProducts = await localDataSource.getSuggestedProducts();
          return Right(localProducts);
        }

        return Right(remoteProducts);
      } on ServerException catch (e) {
        // If remote fails, try local fallback
        try {
          final localProducts = await localDataSource.getSuggestedProducts();
          return Right(localProducts);
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        // If remote fails, try local fallback
        try {
          final localProducts = await localDataSource.getSuggestedProducts();
          return Right(localProducts);
        } on CacheException {
          return Left(ServerFailure(message: 'Remote failed: $e'));
        }
      }
    } else {
      // No internet connection, use local data
      try {
        final localProducts = await localDataSource.getSuggestedProducts();
        return Right(localProducts);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(
          CacheFailure(
            message: 'Failed to get cached suggested products: ${e.toString()}',
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProducts(String query) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.searchProducts(query);

        // If Supabase returns empty results, fall back to local data for demo purposes
        if (remoteProducts.isEmpty) {
          final localProducts = await localDataSource.searchProducts(query);
          return Right(localProducts);
        }

        return Right(remoteProducts);
      } on ServerException catch (e) {
        // If remote fails, try local fallback
        try {
          final localProducts = await localDataSource.searchProducts(query);
          return Right(localProducts);
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        // If remote fails, try local fallback
        try {
          final localProducts = await localDataSource.searchProducts(query);
          return Right(localProducts);
        } on CacheException {
          return Left(ServerFailure(message: 'Remote failed: $e'));
        }
      }
    } else {
      // No internet connection, use local data
      try {
        final localProducts = await localDataSource.searchProducts(query);
        return Right(localProducts);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        return Left(
          CacheFailure(
            message: 'Failed to search cached products: ${e.toString()}',
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> searchProductsByImage(
    String imagePath,
  ) async {
    // Placeholder implementation for image search
    try {
      // For now, return suggested products as placeholder
      final products = await localDataSource.getSuggestedProducts();
      return Right(products);
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Failed to search products by image: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProducts() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getProducts();

        // If Supabase returns empty results, fall back to local data for demo purposes
        if (remoteProducts.isEmpty) {
          final localProducts = await localDataSource.getProducts();
          return Right(localProducts);
        }

        return Right(remoteProducts);
      } on ServerException catch (e) {
        // If remote fails, try local fallback
        try {
          final localProducts = await localDataSource.getProducts();
          return Right(localProducts);
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        log('Unexpected error in getProducts: $e');
        return Left(ServerFailure(message: 'Failed to get products: $e'));
      }
    } else {
      try {
        final localProducts = await localDataSource.getProducts();
        return Right(localProducts);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        log('Unexpected error in getProducts (offline): $e');
        return Left(CacheFailure(message: 'Failed to get cached products: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, Product>> getProductById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProduct = await remoteDataSource.getProductById(id);
        return Right(remoteProduct);
      } on ServerException catch (e) {
        // If remote fails, try local fallback
        try {
          final localProduct = await localDataSource.getProductById(id);
          return Right(localProduct);
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        log('Unexpected error in getProductById: $e');
        return Left(ServerFailure(message: 'Failed to get product: $e'));
      }
    } else {
      try {
        final localProduct = await localDataSource.getProductById(id);
        return Right(localProduct);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        log('Unexpected error in getProductById (offline): $e');
        return Left(CacheFailure(message: 'Failed to get cached product: $e'));
      }
    }
  }

  @override
  Future<Either<Failure, List<Category>>> getCategories() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCategories = await remoteDataSource.getCategories();

        // If Supabase returns empty results, fall back to local data for demo purposes
        if (remoteCategories.isEmpty) {
          final localCategories = await localDataSource.getCategories();
          return Right(localCategories);
        }

        return Right(remoteCategories);
      } on ServerException catch (e) {
        // If remote fails, try local fallback
        try {
          final localCategories = await localDataSource.getCategories();
          return Right(localCategories);
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        log('Unexpected error in getCategories: $e');
        return Left(ServerFailure(message: 'Failed to get categories: $e'));
      }
    } else {
      try {
        final localCategories = await localDataSource.getCategories();
        return Right(localCategories);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        log('Unexpected error in getCategories (offline): $e');
        return Left(
          CacheFailure(message: 'Failed to get cached categories: $e'),
        );
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getProductsByCategory(
    String categoryId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getProductsByCategory(
          categoryId,
        );

        // If Supabase returns empty results, fall back to local data for demo purposes
        if (remoteProducts.isEmpty) {
          final localProducts = await localDataSource.getProductsByCategory(
            categoryId,
          );
          return Right(localProducts);
        }

        return Right(remoteProducts);
      } on ServerException catch (e) {
        // If remote fails, try local fallback
        try {
          final localProducts = await localDataSource.getProductsByCategory(
            categoryId,
          );
          return Right(localProducts);
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        log('Unexpected error in getProductsByCategory: $e');
        return Left(
          ServerFailure(message: 'Failed to get products by category: $e'),
        );
      }
    } else {
      try {
        final localProducts = await localDataSource.getProductsByCategory(
          categoryId,
        );
        return Right(localProducts);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        log('Unexpected error in getProductsByCategory (offline): $e');
        return Left(
          CacheFailure(
            message: 'Failed to get cached products by category: $e',
          ),
        );
      }
    }
  }

  @override
  Future<Either<Failure, List<Product>>> getSimilarProducts(
    String productId,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteProducts = await remoteDataSource.getSimilarProducts(
          productId,
        );
        log('Similar products: $remoteProducts');

        // If Supabase returns empty results, fall back to local data for demo purposes
        if (remoteProducts.isEmpty) {
          final localProducts = await localDataSource.getSimilarProducts(
            productId,
          );
          log('Similar products (local): $localProducts');
          return Right(localProducts);
        }

        return Right(remoteProducts);
      } on ServerException catch (e) {
        // If remote fails, try local fallback
        try {
          final localProducts = await localDataSource.getSimilarProducts(
            productId,
          );
          return Right(localProducts);
        } on CacheException {
          return Left(ServerFailure(message: e.message));
        }
      } catch (e) {
        log('Unexpected error in getSimilarProducts: $e');
        return Left(
          ServerFailure(message: 'Failed to get similar products: $e'),
        );
      }
    } else {
      try {
        final localProducts = await localDataSource.getSimilarProducts(
          productId,
        );
        return Right(localProducts);
      } on CacheException catch (e) {
        return Left(CacheFailure(message: e.message));
      } catch (e) {
        log('Unexpected error in getSimilarProducts (offline): $e');
        return Left(
          CacheFailure(message: 'Failed to get cached similar products: $e'),
        );
      }
    }
  }
}
