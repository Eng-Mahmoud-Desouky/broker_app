part of 'cart_bloc.dart';

/// Base class for cart events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load cart items
class CartLoadItems extends CartEvent {
  const CartLoadItems();
}

/// Event to add item to cart
class CartAddItem extends CartEvent {
  final String productName;
  final String price;
  final String? imageUrl;
  final List<String>? images;
  final String productUrl;
  final String platform;
  final String? rating;
  final Map<String, dynamic>? metadata;

  const CartAddItem({
    required this.productName,
    required this.price,
    this.imageUrl,
    this.images,
    required this.productUrl,
    required this.platform,
    this.rating,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        productName,
        price,
        imageUrl,
        images,
        productUrl,
        platform,
        rating,
        metadata,
      ];
}

/// Event to update item quantity
class CartUpdateQuantity extends CartEvent {
  final String itemId;
  final int quantity;

  const CartUpdateQuantity({
    required this.itemId,
    required this.quantity,
  });

  @override
  List<Object> get props => [itemId, quantity];
}

/// Event to remove item from cart
class CartRemoveItem extends CartEvent {
  final String itemId;

  const CartRemoveItem({required this.itemId});

  @override
  List<Object> get props => [itemId];
}

/// Event to clear cart
class CartClear extends CartEvent {
  const CartClear();
}

/// Event to refresh cart
class CartRefresh extends CartEvent {
  const CartRefresh();
}

/// Event when cart items stream updates
class CartItemsUpdated extends CartEvent {
  final List<CartItem> items;

  const CartItemsUpdated(this.items);

  @override
  List<Object> get props => [items];
}

