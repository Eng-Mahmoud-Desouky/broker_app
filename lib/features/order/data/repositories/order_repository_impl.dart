import 'package:dartz/dartz.dart' hide Order;
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../../cart/domain/entities/cart_item.dart';
import '../../domain/entities/order.dart';
import '../../../pricing/domain/repositories/pricing_repository.dart';
import '../../../wallet/domain/repositories/wallet_repository.dart';
import '../../domain/entities/shipping_method.dart';
import '../../domain/repositories/order_repository.dart';
import '../datasources/order_remote_data_source.dart';

class OrderRepositoryImpl implements OrderRepository {
  final OrderRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient;
  final WalletRepository walletRepository;
  final PricingRepository pricingRepository;

  OrderRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseClient,
    required this.walletRepository,
    required this.pricingRepository,
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

      // Step 1: Get pricing settings and calculate total
      final pricingSettings = await pricingRepository.getPricingSettings();
      final pricingResult = await pricingRepository.calculateOrderPricing(
        items: cartItems,
        settings: pricingSettings,
        shippingMethod: shippingMethod,
      );

      // Step 2: Check wallet balance
      final walletEither = await walletRepository.getWalletBalance(
        _currentUserId!,
      );
      final walletBalance = walletEither.fold((l) => 0.0, (r) => r.balance);

      if (walletBalance < pricingResult.total) {
        return Left(
          ValidationFailure(
            message:
                'رصيد المحفظة غير كافٍ. الرصيد الحالي: \$${walletBalance.toStringAsFixed(2)}، والمبلغ المطلوب: \$${pricingResult.total.toStringAsFixed(2)}',
          ),
        );
      }

      final order = await remoteDataSource.createOrder(
        userId: _currentUserId!,
        cartItems: cartItems,
        addressId: addressId,
        shippingMethod: shippingMethod,
        totalPrice: pricingResult.total,
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
