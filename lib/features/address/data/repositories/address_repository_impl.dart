import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/error/exceptions.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/user_address.dart';
import '../../domain/repositories/address_repository.dart';
import '../datasources/address_remote_data_source.dart';
import '../models/user_address_model.dart';

class AddressRepositoryImpl implements AddressRepository {
  final AddressRemoteDataSource remoteDataSource;
  final SupabaseClient supabaseClient;

  AddressRepositoryImpl({
    required this.remoteDataSource,
    required this.supabaseClient,
  });

  @override
  Future<Either<Failure, List<UserAddress>>> getUserAddresses() async {
    try {
      final userId = await _getCurrentUserId();
      final addresses = await remoteDataSource.getUserAddresses(userId);
      return Right(addresses);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'حدث خطأ غير متوقع'));
    }
  }

  @override
  Future<Either<Failure, UserAddress>> addAddress(UserAddress address) async {
    try {
      final addressModel = UserAddressModel.fromEntity(address);
      final added = await remoteDataSource.addAddress(addressModel);
      return Right(added);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل إضافة العنوان'));
    }
  }

  @override
  Future<Either<Failure, UserAddress>> updateAddress(
    UserAddress address,
  ) async {
    try {
      final addressModel = UserAddressModel.fromEntity(address);
      final updated = await remoteDataSource.updateAddress(addressModel);
      return Right(updated);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل تحديث العنوان'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAddress(String addressId) async {
    try {
      await remoteDataSource.deleteAddress(addressId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل حذف العنوان'));
    }
  }

  @override
  Future<Either<Failure, void>> setDefaultAddress(String addressId) async {
    try {
      final userId = await _getCurrentUserId();
      await remoteDataSource.setDefaultAddress(userId, addressId);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل تعيين العنوان الافتراضي'));
    }
  }

  @override
  Future<Either<Failure, UserAddress?>> getDefaultAddress() async {
    try {
      final userId = await _getCurrentUserId();
      final address = await remoteDataSource.getDefaultAddress(userId);
      return Right(address);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: 'فشل جلب العنوان الافتراضي'));
    }
  }

  Future<String> _getCurrentUserId() async {
    try {
      // Get user ID from Supabase auth
      final userId = supabaseClient.auth.currentUser?.id;
      if (userId == null) {
        throw ServerException(message: 'المستخدم غير مسجل الدخول');
      }
      return userId;
    } catch (e) {
      throw ServerException(message: 'فشل الحصول على معرف المستخدم');
    }
  }
}
