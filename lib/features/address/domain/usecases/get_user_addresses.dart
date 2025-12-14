import 'package:dartz/dartz.dart' hide Order;

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_address.dart';
import '../repositories/address_repository.dart';

/// Get all user addresses
class GetUserAddresses implements UseCase<List<UserAddress>, NoParams> {
  final AddressRepository repository;

  GetUserAddresses(this.repository);

  @override
  Future<Either<Failure, List<UserAddress>>> call(NoParams params) async {
    return await repository.getUserAddresses();
  }
}
