import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../models/cart_item_model.dart';

/// Remote data source for cart operations
abstract class CartRemoteDataSource {
  /// Add item to cart
  Future<CartItemModel> addToCart({
    required String userId,
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
  });

  /// Get all cart items for user
  Future<List<CartItemModel>> getCartItems(String userId);

  /// Update cart item quantity
  Future<CartItemModel> updateQuantity({
    required String itemId,
    required int quantity,
  });

  /// Remove item from cart
  Future<void> removeFromCart(String itemId);

  /// Clear all cart items for user
  Future<void> clearCart(String userId);

  /// Get cart items count
  Future<int> getCartItemsCount(String userId);

  /// Stream of cart items for real-time updates
  Stream<List<CartItemModel>> watchCartItems(String userId);
}

class CartRemoteDataSourceImpl implements CartRemoteDataSource {
  final SupabaseClient supabaseClient;

  CartRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<CartItemModel> addToCart({
    required String userId,
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
      final response =
          await supabaseClient
              .from('cart_items')
              .insert({
                'user_id': userId,
                'product_name': productName,
                'price': price,
                'image_url': imageUrl,
                'images': images,
                'product_url': productUrl,
                'platform': platform,
                'rating': rating,
                'metadata': metadata,
                'weight_kg': weightKg,
                'dimensions': dimensions,
                'raw_specs': rawSpecs,
                'quantity': 1,
              })
              .select()
              .single();

      return CartItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to add to cart: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to add to cart: ${e.toString()}');
    }
  }

  @override
  Future<List<CartItemModel>> getCartItems(String userId) async {
    try {
      final response = await supabaseClient
          .from('cart_items')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List<dynamic>)
          .map((json) => CartItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to get cart items: ${e.message}');
    } catch (e) {
      throw ServerException(
        message: 'Failed to get cart items: ${e.toString()}',
      );
    }
  }

  @override
  Future<CartItemModel> updateQuantity({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final response =
          await supabaseClient
              .from('cart_items')
              .update({
                'quantity': quantity,
                'updated_at': DateTime.now().toIso8601String(),
              })
              .eq('id', itemId)
              .select()
              .single();

      return CartItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to update quantity: ${e.message}');
    } catch (e) {
      throw ServerException(
        message: 'Failed to update quantity: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> removeFromCart(String itemId) async {
    try {
      await supabaseClient.from('cart_items').delete().eq('id', itemId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to remove from cart: ${e.message}',
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to remove from cart: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> clearCart(String userId) async {
    try {
      await supabaseClient.from('cart_items').delete().eq('user_id', userId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to clear cart: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'Failed to clear cart: ${e.toString()}');
    }
  }

  @override
  Future<int> getCartItemsCount(String userId) async {
    try {
      final response = await supabaseClient
          .from('cart_items')
          .select('id')
          .eq('user_id', userId);

      return (response as List<dynamic>).length;
    } on PostgrestException catch (e) {
      throw ServerException(message: 'Failed to get cart count: ${e.message}');
    } catch (e) {
      throw ServerException(
        message: 'Failed to get cart count: ${e.toString()}',
      );
    }
  }

  @override
  Stream<List<CartItemModel>> watchCartItems(String userId) {
    try {
      return supabaseClient
          .from('cart_items')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .map(
            (data) => data.map((json) => CartItemModel.fromJson(json)).toList(),
          );
    } catch (e) {
      throw ServerException(
        message: 'Failed to watch cart items: ${e.toString()}',
      );
    }
  }
}
