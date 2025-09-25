part of 'product_list_bloc.dart';

abstract class ProductListState extends Equatable {
  const ProductListState();

  @override
  List<Object> get props => [];
}

class ProductListInitial extends ProductListState {}

class ProductListLoading extends ProductListState {}

class ProductListLoaded extends ProductListState {
  final List<Product> products;

  const ProductListLoaded({required this.products});

  @override
  List<Object> get props => [products];
}

class ProductListRefreshing extends ProductListState {
  final List<Product> products;

  const ProductListRefreshing({required this.products});

  @override
  List<Object> get props => [products];
}

class ProductListEmpty extends ProductListState {}

class ProductListError extends ProductListState {
  final String message;

  const ProductListError({required this.message});

  @override
  List<Object> get props => [message];
}

// Category states
class CategoriesLoading extends ProductListState {}

class CategoriesLoaded extends ProductListState {
  final List<Category> categories;

  const CategoriesLoaded({required this.categories});

  @override
  List<Object> get props => [categories];
}

class CategoriesError extends ProductListState {
  final String message;

  const CategoriesError({required this.message});

  @override
  List<Object> get props => [message];
}
