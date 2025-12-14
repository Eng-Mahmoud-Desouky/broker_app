import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/address_repository.dart';

/// Set address as default
class SetDefaultAddress implements UseCase<void, SetDefaultAddressParams> {
  final AddressRepository repository;

  SetDefaultAddress(this.repository);

  @override
  Future<Either<Failure, void>> call(SetDefaultAddressParams params) async {
    return await repository.setDefaultAddress(params.addressId);
  }
}

class SetDefaultAddressParams extends Equatable {
  final String addressId;

  const SetDefaultAddressParams({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}
