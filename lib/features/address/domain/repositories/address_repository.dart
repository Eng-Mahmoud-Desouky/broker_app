import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/user_address.dart';

/// Address repository interface
abstract class AddressRepository {
  /// Get all addresses for current user
  Future<Either<Failure, List<UserAddress>>> getUserAddresses();

  /// Add new address
  Future<Either<Failure, UserAddress>> addAddress(UserAddress address);

  /// Update existing address
  Future<Either<Failure, UserAddress>> updateAddress(UserAddress address);

  /// Delete address
  Future<Either<Failure, void>> deleteAddress(String addressId);

  /// Set address as default
  Future<Either<Failure, void>> setDefaultAddress(String addressId);

  /// Get default address
  Future<Either<Failure, UserAddress?>> getDefaultAddress();
}
