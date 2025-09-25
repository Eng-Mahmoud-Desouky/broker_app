import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/product.dart';
import '../../domain/entities/category.dart';
import '../../domain/usecases/get_products.dart';
import '../../domain/usecases/get_categories.dart';
import '../../domain/usecases/get_products_by_category.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final GetProducts getProducts;
  final GetCategories getCategories;
  final GetProductsByCategory getProductsByCategory;

  ProductListBloc({
    required this.getProducts,
    required this.getCategories,
    required this.getProductsByCategory,
  }) : super(ProductListInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<RefreshProducts>(_onRefreshProducts);
    on<LoadCategories>(_onLoadCategories);
    on<LoadProductsByCategory>(_onLoadProductsByCategory);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductListState> emit,
  ) async {
    emit(ProductListLoading());

    final result = await getProducts(NoParams());

    result.fold(
      (failure) => emit(ProductListError(message: failure.message)),
      (products) {
        if (products.isEmpty) {
          emit(ProductListEmpty());
        } else {
          emit(ProductListLoaded(products: products));
        }
      },
    );
  }

  Future<void> _onRefreshProducts(
    RefreshProducts event,
    Emitter<ProductListState> emit,
  ) async {
    if (state is ProductListLoaded) {
      final currentProducts = (state as ProductListLoaded).products;
      emit(ProductListRefreshing(products: currentProducts));
    }

    final result = await getProducts(NoParams());

    result.fold(
      (failure) => emit(ProductListError(message: failure.message)),
      (products) {
        if (products.isEmpty) {
          emit(ProductListEmpty());
        } else {
          emit(ProductListLoaded(products: products));
        }
      },
    );
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<ProductListState> emit,
  ) async {
    emit(CategoriesLoading());

    final result = await getCategories(NoParams());

    result.fold(
      (failure) => emit(CategoriesError(message: failure.message)),
      (categories) => emit(CategoriesLoaded(categories: categories)),
    );
  }

  Future<void> _onLoadProductsByCategory(
    LoadProductsByCategory event,
    Emitter<ProductListState> emit,
  ) async {
    emit(ProductListLoading());

    final result = await getProductsByCategory(
      GetProductsByCategoryParams(categoryId: event.categoryId),
    );

    result.fold(
      (failure) => emit(ProductListError(message: failure.message)),
      (products) {
        if (products.isEmpty) {
          emit(ProductListEmpty());
        } else {
          emit(ProductListLoaded(products: products));
        }
      },
    );
  }
}
