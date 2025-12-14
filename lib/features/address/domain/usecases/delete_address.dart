import 'package:dartz/dartz.dart' hide Order;
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/address_repository.dart';

/// Delete address
class DeleteAddress implements UseCase<void, DeleteAddressParams> {
  final AddressRepository repository;

  DeleteAddress(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteAddressParams params) async {
    return await repository.deleteAddress(params.addressId);
  }
}

class DeleteAddressParams extends Equatable {
  final String addressId;

  const DeleteAddressParams({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}
