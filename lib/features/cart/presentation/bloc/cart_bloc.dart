import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/cart_item.dart';
import '../../domain/usecases/add_to_cart.dart';
import '../../domain/usecases/clear_cart.dart';
import '../../domain/usecases/get_cart_items.dart';
import '../../domain/usecases/remove_from_cart.dart';
import '../../domain/usecases/update_cart_quantity.dart';

part 'cart_event.dart';
part 'cart_state.dart';

class CartBloc extends Bloc<CartEvent, CartState> {
  final GetCartItems getCartItems;
  final AddToCart addToCart;
  final UpdateCartQuantity updateCartQuantity;
  final RemoveFromCart removeFromCart;
  final ClearCart clearCart;

  StreamSubscription<List<CartItem>>? _cartItemsSubscription;

  CartBloc({
    required this.getCartItems,
    required this.addToCart,
    required this.updateCartQuantity,
    required this.removeFromCart,
    required this.clearCart,
  }) : super(const CartInitial()) {
    on<CartLoadItems>(_onLoadItems);
    on<CartAddItem>(_onAddItem);
    on<CartUpdateQuantity>(_onUpdateQuantity);
    on<CartRemoveItem>(_onRemoveItem);
    on<CartClear>(_onClear);
    on<CartRefresh>(_onRefresh);
    on<CartItemsUpdated>(_onItemsUpdated);
  }

  Future<void> _onLoadItems(
    CartLoadItems event,
    Emitter<CartState> emit,
  ) async {
    emit(const CartLoading());

    final result = await getCartItems(NoParams());

    result.fold((failure) => emit(CartError(message: failure.message)), (
      items,
    ) {
      if (items.isEmpty) {
        emit(const CartEmpty());
      } else {
        emit(_buildLoadedState(items));
      }
    });
  }

  Future<void> _onAddItem(CartAddItem event, Emitter<CartState> emit) async {
    emit(const CartAddingItem());

    final result = await addToCart(
      AddToCartParams(
        productName: event.productName,
        price: event.price,
        imageUrl: event.imageUrl,
        images: event.images,
        productUrl: event.productUrl,
        platform: event.platform,
        rating: event.rating,
        metadata: event.metadata,
        weightKg: event.weightKg,
        dimensions: event.dimensions,
        rawSpecs: event.rawSpecs,
      ),
    );

    result.fold((failure) => emit(CartError(message: failure.message)), (item) {
      emit(CartItemAdded(item: item));
      // Reload cart items after adding
      add(const CartLoadItems());
    });
  }

  Future<void> _onUpdateQuantity(
    CartUpdateQuantity event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    emit(CartUpdatingQuantity(itemId: event.itemId));

    final result = await updateCartQuantity(
      UpdateCartQuantityParams(itemId: event.itemId, quantity: event.quantity),
    );

    result.fold(
      (failure) {
        emit(CartError(message: failure.message));
        // Restore previous state if available
        if (currentState is CartLoaded) {
          emit(currentState);
        }
      },
      (item) {
        emit(const CartOperationSuccess(message: 'Quantity updated'));
        // Reload cart items after updating
        add(const CartLoadItems());
      },
    );
  }

  Future<void> _onRemoveItem(
    CartRemoveItem event,
    Emitter<CartState> emit,
  ) async {
    final currentState = state;
    emit(CartRemovingItem(itemId: event.itemId));

    final result = await removeFromCart(
      RemoveFromCartParams(itemId: event.itemId),
    );

    result.fold(
      (failure) {
        emit(CartError(message: failure.message));
        // Restore previous state if available
        if (currentState is CartLoaded) {
          emit(currentState);
        }
      },
      (_) {
        emit(const CartOperationSuccess(message: 'Item removed from cart'));
        // Reload cart items after removing
        add(const CartLoadItems());
      },
    );
  }

  Future<void> _onClear(CartClear event, Emitter<CartState> emit) async {
    emit(const CartClearing());

    final result = await clearCart(NoParams());

    result.fold((failure) => emit(CartError(message: failure.message)), (_) {
      emit(const CartOperationSuccess(message: 'Cart cleared'));
      emit(const CartEmpty());
    });
  }

  Future<void> _onRefresh(CartRefresh event, Emitter<CartState> emit) async {
    // Don't show loading state on refresh
    final result = await getCartItems(NoParams());

    result.fold((failure) => emit(CartError(message: failure.message)), (
      items,
    ) {
      if (items.isEmpty) {
        emit(const CartEmpty());
      } else {
        emit(_buildLoadedState(items));
      }
    });
  }

  void _onItemsUpdated(CartItemsUpdated event, Emitter<CartState> emit) {
    if (event.items.isEmpty) {
      emit(const CartEmpty());
    } else {
      emit(_buildLoadedState(event.items));
    }
  }

  CartLoaded _buildLoadedState(List<CartItem> items) {
    final totalItems = items.fold<int>(0, (sum, item) => sum + item.quantity);

    // Calculate total price
    final totalPrice = items.fold<double>(0.0, (sum, item) {
      return sum + (item.price * item.quantity);
    });

    return CartLoaded(
      items: items,
      totalItems: totalItems,
      totalPrice: totalPrice,
    );
  }

  @override
  Future<void> close() {
    _cartItemsSubscription?.cancel();
    return super.close();
  }
}
