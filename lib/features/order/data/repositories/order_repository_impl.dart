import 'package:dartz/dartz.dart' hide Order;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../domain/entities/shipping_method.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseClient,
  });

  String? get _currentUserId => supabaseClient.auth.currentUser?.id;

  @override
  Future<Either<Failure, Order>> createOrder({
    required List<CartItem> cartItems,
    required String addressId,
    required ShippingMethod shippingMethod,
    String? promoCode,
  }) async {
    try {
      if (_currentUserId == null) {
        return Left(AuthenticationFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      if (cartItems.isEmpty) {
        return Left(ValidationFailure(message: 'السلة فارغة'));
      }

      final order = await remoteDataSource.createOrder(
        userId: _currentUserId!,
        cartItems: cartItems,
        addressId: addressId,
        shippingMethod: shippingMethod,
        promoCode: promoCode,
      );

      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل إنشاء الطلب: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Order>>> getUserOrders() async {
    try {
      if (_currentUserId == null) {
        return Left(AuthenticationFailure(message: 'المستخدم غير مسجل الدخول'));
      }

      final orders = await remoteDataSource.getUserOrders(_currentUserId!);
      return Right(orders);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } on AuthException catch (e) {
      return Left(AuthenticationFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل جلب الطلبات: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderById(String orderId) async {
    try {
      final order = await remoteDataSource.getOrderById(orderId);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل جلب الطلب: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Order>> getOrderByReference(
    String referenceNumber,
  ) async {
    try {
      final order = await remoteDataSource.getOrderByReference(referenceNumber);
      return Right(order);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل جلب الطلب: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelOrder(String orderId) async {
    try {
      await remoteDataSource.cancelOrder(orderId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل إلغاء الطلب: ${e.toString()}'));
    }
  }
}
