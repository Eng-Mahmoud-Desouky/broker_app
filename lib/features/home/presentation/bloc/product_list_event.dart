part of 'product_list_bloc.dart';

abstract class ProductListEvent extends Equatable {
  const ProductListEvent();

  @override
  List<Object> get props => [];
}

class LoadProducts extends ProductListEvent {
  const LoadProducts();
}

class RefreshProducts extends ProductListEvent {
  const RefreshProducts();
}

class LoadCategories extends ProductListEvent {
  const LoadCategories();
}

class LoadProductsByCategory extends ProductListEvent {
  final String categoryId;

  const LoadProductsByCategory({required this.categoryId});

  @override
  List<Object> get props => [categoryId];
}
