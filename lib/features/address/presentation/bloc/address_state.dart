part of 'address_bloc.dart';

/// Address states
abstract class AddressState extends Equatable {
  const AddressState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class AddressInitial extends AddressState {}

/// Loading state
class AddressLoading extends AddressState {}

/// Loaded state with addresses
class AddressLoaded extends AddressState {
  final List<UserAddress> addresses;

  const AddressLoaded({required this.addresses});

  /// Get default address
  UserAddress? get defaultAddress {
    try {
      return addresses.firstWhere((address) => address.isDefault);
    } catch (e) {
      return null;
    }
  }

  @override
  List<Object?> get props => [addresses];
}

/// Empty state when no addresses
class AddressEmpty extends AddressState {}

/// Address added successfully
class AddressAdded extends AddressState {
  final UserAddress address;

  const AddressAdded({required this.address});

  @override
  List<Object?> get props => [address];
}

/// Address deleted successfully
class AddressDeleted extends AddressState {
  const AddressDeleted();
}

/// Error state
class AddressError extends AddressState {
  final String message;

  const AddressError({required this.message});

  @override
  List<Object?> get props => [message];
}
