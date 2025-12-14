import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_address.dart';
import '../repositories/address_repository.dart';

/// Add new address
class AddAddress implements UseCase<UserAddress, AddAddressParams> {
  final AddressRepository repository;

  AddAddress(this.repository);

  @override
  Future<Either<Failure, UserAddress>> call(AddAddressParams params) async {
    return await repository.addAddress(params.address);
  }
}

class AddAddressParams extends Equatable {
  final UserAddress address;

  const AddAddressParams({required this.address});

  @override
  List<Object?> get props => [address];
}
