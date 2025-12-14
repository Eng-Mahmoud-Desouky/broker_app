import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user_address.dart';
import '../../domain/usecases/add_address.dart';
import '../../domain/usecases/delete_address.dart';
import '../../domain/usecases/get_user_addresses.dart';
import '../../domain/usecases/set_default_address.dart';

part 'address_event.dart';
part 'address_state.dart';

/// Address BLoC for managing user addresses
class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final GetUserAddresses getUserAddresses;
  final AddAddress addAddress;
  final SetDefaultAddress setDefaultAddress;
  final DeleteAddress deleteAddress;

  AddressBloc({
    required this.getUserAddresses,
    required this.addAddress,
    required this.setDefaultAddress,
    required this.deleteAddress,
  }) : super(AddressInitial()) {
    on<AddressLoadAll>(_onLoadAll);
    on<AddressAdd>(_onAdd);
    on<AddressSetDefault>(_onSetDefault);
    on<AddressDelete>(_onDelete);
  }

  Future<void> _onLoadAll(
    AddressLoadAll event,
    Emitter<AddressState> emit,
  ) async {
    emit(AddressLoading());

    final result = await getUserAddresses(NoParams());

    result.fold(
      (failure) => emit(AddressError(message: _mapFailureToMessage(failure))),
      (addresses) {
        if (addresses.isEmpty) {
          emit(AddressEmpty());
        } else {
          emit(AddressLoaded(addresses: addresses));
        }
      },
    );
  }

  Future<void> _onAdd(AddressAdd event, Emitter<AddressState> emit) async {
    emit(AddressLoading());

    final result = await addAddress(AddAddressParams(address: event.address));

    result.fold(
      (failure) => emit(AddressError(message: _mapFailureToMessage(failure))),
      (address) {
        emit(AddressAdded(address: address));
        // Reload all addresses
        add(const AddressLoadAll());
      },
    );
  }

  Future<void> _onSetDefault(
    AddressSetDefault event,
    Emitter<AddressState> emit,
  ) async {
    final currentState = state;
    emit(AddressLoading());

    final result = await setDefaultAddress(
      SetDefaultAddressParams(addressId: event.addressId),
    );

    result.fold(
      (failure) {
        emit(AddressError(message: _mapFailureToMessage(failure)));
        // Restore previous state if available
        if (currentState is AddressLoaded) {
          emit(currentState);
        }
      },
      (_) {
        // Reload all addresses to reflect changes
        add(const AddressLoadAll());
      },
    );
  }

  Future<void> _onDelete(
    AddressDelete event,
    Emitter<AddressState> emit,
  ) async {
    final currentState = state;
    emit(AddressLoading());

    final result = await deleteAddress(
      DeleteAddressParams(addressId: event.addressId),
    );

    result.fold(
      (failure) {
        emit(AddressError(message: _mapFailureToMessage(failure)));
        // Restore previous state if available
        if (currentState is AddressLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(const AddressDeleted());
        // Reload all addresses
        add(const AddressLoadAll());
      },
    );
  }

  String _mapFailureToMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is AuthenticationFailure) {
      return 'يرجى تسجيل الدخول أولاً';
    } else {
      return 'حدث خطأ غير متوقع';
    }
  }
}
