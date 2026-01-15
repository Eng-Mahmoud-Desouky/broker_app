import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/shipping_method.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

/// Remote data source for order operations
abstract class OrderRemoteDataSource {
  /// Create new order from cart items
  Future<OrderModel> createOrder({
    required String userId,
    required List<CartItem> cartItems,
    required String addressId,
    required ShippingMethod shippingMethod,
    String? promoCode,
  });

  /// Get all orders for user
  Future<List<OrderModel>> getUserOrders(String userId);

  /// Get order by ID
  Future<OrderModel> getOrderById(String orderId);

  /// Get order by reference number
  Future<OrderModel> getOrderByReference(String referenceNumber);

  /// Cancel order
  Future<void> cancelOrder(String orderId);
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final SupabaseClient supabaseClient;

  OrderRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<OrderModel> createOrder({
    required String userId,
    required List<CartItem> cartItems,
    required String addressId,
    required ShippingMethod shippingMethod,
    String? promoCode,
  }) async {
    try {
      // Step 1: Get the address
      final addressResponse =
          await supabaseClient
              .from('user_addresses')
              .select()
              .eq('id', addressId)
              .single();

      // Step 2: Calculate total weight and base price
      double totalWeight = 0.01; // Minimum value to satisfy DB constraint
      double basePrice = 0.0;
      List<double> weights = [];
      List<double> prices = [];

      for (var item in cartItems) {
        // Calculate weight if available
        if (item.weightKg != null) {
          weights.add(item.weightKg! * item.quantity);
        }

        // Calculate price
        final itemPrice = item.priceValue;
        if (itemPrice != null) {
          prices.add(itemPrice * item.quantity);
        }
      }

      // Set total weight
      totalWeight =
          weights.isNotEmpty
              ? weights.fold<double>(0.0, (sum, weight) => sum + weight)
              : 0.01;

      // Calculate base price (sum of all item prices)
      if (prices.length == cartItems.length) {
        basePrice = prices.fold<double>(0.0, (sum, price) => sum + price);
      }

      // Step 3: Call RPC function to create order with promo
      // Generate a temporary reference number (will be replaced by trigger)
      final tempReference = 'ORD-${DateTime.now().millisecondsSinceEpoch}';

      final rpcResponse = await supabaseClient.rpc(
        'create_order_with_promo',
        params: {
          'p_user_id': userId,
          'p_reference_number': tempReference,
          'p_shipping_address': addressResponse,
          'p_shipping_method': shippingMethod.toDbValue(),
          'p_total_weight_kg': totalWeight,
          'p_base_price': basePrice,
          'p_promo_code': promoCode,
        },
      );

      // RPC returns a table (list) with: order_id, final_price, discount_amount
      // Extract from the first (and only) row
      final responseData =
          rpcResponse is List && rpcResponse.isNotEmpty
              ? rpcResponse[0] as Map<String, dynamic>
              : rpcResponse as Map<String, dynamic>;

      final orderId = responseData['order_id'] as String;
      final discountAmount =
          responseData['discount_amount'] != null
              ? (responseData['discount_amount'] as num).toDouble()
              : null;

      // Step 4: Create order items
      final List<Map<String, dynamic>> itemsData = [];

      for (var item in cartItems) {
        final weightKg = item.weightKg ?? 0.01;
        itemsData.add({
          'order_id': orderId,
          'product_name': item.productName,
          'product_url': item.productUrl,
          'platform': item.platform,
          'price': item.price,
          'quantity': item.quantity,
          'weight_kg': weightKg,
          'image_url': item.imageUrl,
          'metadata': item.metadata,
        });
      }

      final itemsResponse =
          await supabaseClient.from('order_items').insert(itemsData).select();

      final orderItems =
          (itemsResponse as List<dynamic>)
              .map(
                (json) => OrderItemModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      // Step 5: Fetch the created order
      final orderResponse =
          await supabaseClient
              .from('orders')
              .select()
              .eq('id', orderId)
              .single();

      // Step 6: Return complete order with items and discount info
      return OrderModel.fromJsonWithItems({
        ...orderResponse,
        'discount_amount': discountAmount,
        'promo_code_used': promoCode, // Use the promo code that was passed
      }, orderItems);
    } on PostgrestException catch (e) {
      // Handle specific promo code errors
      if (e.message.contains('كود الخصم') ||
          e.message.contains('promo') ||
          e.message.contains('الخصم')) {
        throw ServerException(message: e.message);
      }
      throw ServerException(message: 'فشل إنشاء الطلب: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'فشل إنشاء الطلب: ${e.toString()}');
    }
  }

  @override
  Future<List<OrderModel>> getUserOrders(String userId) async {
    try {
      // Get orders
      final ordersResponse = await supabaseClient
          .from('orders')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      final List<OrderModel> orders = [];

      for (var orderJson in ordersResponse as List<dynamic>) {
        final orderId = orderJson['id'] as String;

        // Get items for this order
        final itemsResponse = await supabaseClient
            .from('order_items')
            .select()
            .eq('order_id', orderId)
            .order('created_at', ascending: false);

        final items =
            (itemsResponse as List<dynamic>)
                .map(
                  (json) =>
                      OrderItemModel.fromJson(json as Map<String, dynamic>),
                )
                .toList();

        orders.add(
          OrderModel.fromJsonWithItems(
            orderJson as Map<String, dynamic>,
            items,
          ),
        );
      }

      return orders;
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل جلب الطلبات: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'فشل جلب الطلبات: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderById(String orderId) async {
    try {
      // Get order
      final orderResponse =
          await supabaseClient
              .from('orders')
              .select()
              .eq('id', orderId)
              .single();

      // Get items
      final itemsResponse = await supabaseClient
          .from('order_items')
          .select()
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      final items =
          (itemsResponse as List<dynamic>)
              .map(
                (json) => OrderItemModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      return OrderModel.fromJsonWithItems(orderResponse, items);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل جلب الطلب: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'فشل جلب الطلب: ${e.toString()}');
    }
  }

  @override
  Future<OrderModel> getOrderByReference(String referenceNumber) async {
    try {
      // Get order
      final orderResponse =
          await supabaseClient
              .from('orders')
              .select()
              .eq('reference_number', referenceNumber)
              .single();

      final orderId = orderResponse['id'] as String;

      // Get items
      final itemsResponse = await supabaseClient
          .from('order_items')
          .select()
          .eq('order_id', orderId)
          .order('created_at', ascending: false);

      final items =
          (itemsResponse as List<dynamic>)
              .map(
                (json) => OrderItemModel.fromJson(json as Map<String, dynamic>),
              )
              .toList();

      return OrderModel.fromJsonWithItems(orderResponse, items);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل جلب الطلب: ${e.message}');
    } catch (e) {
      throw ServerException(message: 'فشل جلب الطلب: ${e.toString()}');
    }
  }

  @override
  Future<void> cancelOrder(String orderId) async {
    try {
      // Check if order can be cancelled (status should be under_review, purchasing, or purchased)
      final orderResponse =
          await supabaseClient
              .from('orders')
              .select('status')
              .eq('id', orderId)
              .single();

      final status = orderResponse['status'] as String;
      // Check against new status values
      if (status != 'under_review' &&
          status != 'purchasing' &&
          status != 'purchased') {
        throw ServerException(message: 'لا يمكن إلغاء هذا الطلب');
      }

      // Update order status to cancelled
      await supabaseClient
          .from('orders')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', orderId);
    } on PostgrestException catch (e) {
      throw ServerException(message: 'فشل إلغاء الطلب: ${e.message}');
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(message: 'فشل إلغاء الطلب: ${e.toString()}');
    }
  }
}
