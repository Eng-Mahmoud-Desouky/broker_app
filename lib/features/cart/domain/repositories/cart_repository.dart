import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/cart_item.dart';

/// Repository interface for cart operations
abstract class CartRepository {
  /// Add item to cart
  Future<Either<Failure, CartItem>> addToCart({
    required String productName,
    required String price,
    String? imageUrl,
    List<String>? images,
    required String productUrl,
    required String platform,
    String? rating,
    Map<String, dynamic>? metadata,
  });

  /// Get all cart items for current user
  Future<Either<Failure, List<CartItem>>> getCartItems();

  /// Update cart item quantity
  Future<Either<Failure, CartItem>> updateQuantity({
    required String itemId,
    required int quantity,
  });

  /// Remove item from cart
  Future<Either<Failure, void>> removeFromCart(String itemId);

  /// Clear all cart items
  Future<Either<Failure, void>> clearCart();

  /// Get cart items count
  Future<Either<Failure, int>> getCartItemsCount();

  /// Stream of cart items for real-time updates
  Stream<List<CartItem>> watchCartItems();
}

