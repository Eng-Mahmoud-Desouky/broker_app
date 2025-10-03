part of 'product_details_bloc.dart';

abstract class ProductDetailsEvent extends Equatable {
  const ProductDetailsEvent();

  @override
  List<Object> get props => [];
}

class LoadProductDetails extends ProductDetailsEvent {
  final String productId;

  const LoadProductDetails({required this.productId});

  @override
  List<Object> get props => [productId];
}

class LoadSimilarProducts extends ProductDetailsEvent {
  final String productId;

  const LoadSimilarProducts({required this.productId});

  @override
  List<Object> get props => [productId];
}
