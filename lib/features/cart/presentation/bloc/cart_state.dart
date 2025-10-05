part of 'cart_bloc.dart';

/// Base class for cart states
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class CartInitial extends CartState {
  const CartInitial();
}

/// Loading state
class CartLoading extends CartState {
  const CartLoading();
}

/// Loaded state with items
class CartLoaded extends CartState {
  final List<CartItem> items;
  final int totalItems;
  final double? totalPrice;

  const CartLoaded({
    required this.items,
    required this.totalItems,
    this.totalPrice,
  });

  @override
  List<Object?> get props => [items, totalItems, totalPrice];

  CartLoaded copyWith({
    List<CartItem>? items,
    int? totalItems,
    double? totalPrice,
  }) {
    return CartLoaded(
      items: items ?? this.items,
      totalItems: totalItems ?? this.totalItems,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}

/// Empty cart state
class CartEmpty extends CartState {
  const CartEmpty();
}

/// Error state
class CartError extends CartState {
  final String message;

  const CartError({required this.message});

  @override
  List<Object> get props => [message];
}

/// Adding item state
class CartAddingItem extends CartState {
  const CartAddingItem();
}

/// Item added successfully state
class CartItemAdded extends CartState {
  final CartItem item;

  const CartItemAdded({required this.item});

  @override
  List<Object> get props => [item];
}

/// Updating quantity state
class CartUpdatingQuantity extends CartState {
  final String itemId;

  const CartUpdatingQuantity({required this.itemId});

  @override
  List<Object> get props => [itemId];
}

/// Removing item state
class CartRemovingItem extends CartState {
  final String itemId;

  const CartRemovingItem({required this.itemId});

  @override
  List<Object> get props => [itemId];
}

/// Clearing cart state
class CartClearing extends CartState {
  const CartClearing();
}

/// Cart operation success state
class CartOperationSuccess extends CartState {
  final String message;

  const CartOperationSuccess({required this.message});

  @override
  List<Object> get props => [message];
}

