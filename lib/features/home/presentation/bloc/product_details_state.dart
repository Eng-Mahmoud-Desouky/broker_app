part of 'product_details_bloc.dart';

abstract class ProductDetailsState extends Equatable {
  const ProductDetailsState();

  @override
  List<Object> get props => [];
}

class ProductDetailsInitial extends ProductDetailsState {}

class ProductDetailsLoading extends ProductDetailsState {}

class ProductDetailsLoaded extends ProductDetailsState {
  final Product product;
  final List<Product> similarProducts;
  final bool isSimilarProductsLoading;
  final bool hasSimilarProductsError;
  final String? similarProductsErrorMessage;

  const ProductDetailsLoaded({
    required this.product,
    this.similarProducts = const [],
    this.isSimilarProductsLoading = false,
    this.hasSimilarProductsError = false,
    this.similarProductsErrorMessage,
  });

  ProductDetailsLoaded copyWith({
    Product? product,
    List<Product>? similarProducts,
    bool? isSimilarProductsLoading,
    bool? hasSimilarProductsError,
    String? similarProductsErrorMessage,
  }) {
    return ProductDetailsLoaded(
      product: product ?? this.product,
      similarProducts: similarProducts ?? this.similarProducts,
      isSimilarProductsLoading:
          isSimilarProductsLoading ?? this.isSimilarProductsLoading,
      hasSimilarProductsError:
          hasSimilarProductsError ?? this.hasSimilarProductsError,
      similarProductsErrorMessage:
          similarProductsErrorMessage ?? this.similarProductsErrorMessage,
    );
  }

  @override
  List<Object> get props => [
    product,
    similarProducts,
    isSimilarProductsLoading,
    hasSimilarProductsError,
    similarProductsErrorMessage ?? '',
  ];
}

class ProductDetailsError extends ProductDetailsState {
  final String message;

  const ProductDetailsError({required this.message});

  @override
  List<Object> get props => [message];
}
