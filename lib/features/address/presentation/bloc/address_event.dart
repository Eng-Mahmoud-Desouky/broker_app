part of 'address_bloc.dart';

/// Address events
abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

/// Load all addresses
class AddressLoadAll extends AddressEvent {
  const AddressLoadAll();
}

/// Add new address
class AddressAdd extends AddressEvent {
  final UserAddress address;

  const AddressAdd({required this.address});

  @override
  List<Object?> get props => [address];
}

/// Set address as default
class AddressSetDefault extends AddressEvent {
  final String addressId;

  const AddressSetDefault({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}

/// Delete address
class AddressDelete extends AddressEvent {
  final String addressId;

  const AddressDelete({required this.addressId});

  @override
  List<Object?> get props => [addressId];
}
