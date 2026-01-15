import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/repositories/cart_repository.dart';
import '../datasources/cart_remote_data_source.dart';

class CartRepositoryImpl implements CartRepository {
  final CartRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient;

  CartRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseClient,
  });

  String? get _currentUserId => supabaseClient.auth.currentUser?.id;

  @override
  Future<Either<Failure, CartItem>> addToCart({
    required String productName,
    required String price,
    String? imageUrl,
    List<String>? images,
    required String productUrl,
    required String platform,
    String? rating,
    Map<String, dynamic>? metadata,
    double? weightKg,
    Map<String, dynamic>? dimensions,
    Map<String, dynamic>? rawSpecs,
  }) async {
    try {
      if (_currentUserId == null) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      final result = await remoteDataSource.addToCart(
        userId: _currentUserId!,
        productName: productName,
        price: price,
        imageUrl: imageUrl,
        images: images,
        productUrl: productUrl,
        platform: platform,
        rating: rating,
        metadata: metadata,
        weightKg: weightKg,
        dimensions: dimensions,
        rawSpecs: rawSpecs,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to add to cart: $e'));
    }
  }

  @override
  Future<Either<Failure, List<CartItem>>> getCartItems() async {
    try {
      if (_currentUserId == null) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      final result = await remoteDataSource.getCartItems(_currentUserId!);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get cart items: $e'));
    }
  }

  @override
  Future<Either<Failure, CartItem>> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    try {
      if (_currentUserId == null) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      if (quantity < 1) {
        return Left(ValidationFailure(message: 'Quantity must be at least 1'));
      }

      final result = await remoteDataSource.updateQuantity(
        itemId: itemId,
        quantity: quantity,
      );

      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to update quantity: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> removeFromCart(String itemId) async {
    try {
      if (_currentUserId == null) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      await remoteDataSource.removeFromCart(itemId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to remove from cart: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> clearCart() async {
    try {
      if (_currentUserId == null) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      await remoteDataSource.clearCart(_currentUserId!);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to clear cart: $e'));
    }
  }

  @override
  Future<Either<Failure, int>> getCartItemsCount() async {
    try {
      if (_currentUserId == null) {
        return Left(AuthenticationFailure(message: 'User not authenticated'));
      }

      final count = await remoteDataSource.getCartItemsCount(_currentUserId!);
      return Right(count);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get cart count: $e'));
    }
  }

  @override
  Stream<List<CartItem>> watchCartItems() {
    if (_currentUserId == null) {
      return Stream.error(
        AuthenticationFailure(message: 'User not authenticated'),
      );
    }

    try {
      return remoteDataSource.watchCartItems(_currentUserId!);
    } catch (e) {
      return Stream.error(
        ServerFailure(message: 'Failed to watch cart items: $e'),
      );
    }
  }
}
