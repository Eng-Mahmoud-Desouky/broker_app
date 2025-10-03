import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/product.dart';
import '../../domain/usecases/get_product_details.dart';
import '../../domain/usecases/get_similar_products.dart';

part 'product_details_event.dart';
part 'product_details_state.dart';

class ProductDetailsBloc
    extends Bloc<ProductDetailsEvent, ProductDetailsState> {
  final GetProductDetails getProductDetails;
  final GetSimilarProducts getSimilarProducts;

  ProductDetailsBloc({
    required this.getProductDetails,
    required this.getSimilarProducts,
  }) : super(ProductDetailsInitial()) {
    on<LoadProductDetails>(_onLoadProductDetails);
    on<LoadSimilarProducts>(_onLoadSimilarProducts);
  }

  Future<void> _onLoadProductDetails(
    LoadProductDetails event,
    Emitter<ProductDetailsState> emit,
  ) async {
    emit(ProductDetailsLoading());

    final result = await getProductDetails(
      GetProductDetailsParams(productId: event.productId),
    );

    result.fold(
      (failure) => emit(ProductDetailsError(message: failure.message)),
      (product) {
        emit(ProductDetailsLoaded(product: product));
        // Automatically load similar products
        add(LoadSimilarProducts(productId: event.productId));
      },
    );
  }

  Future<void> _onLoadSimilarProducts(
    LoadSimilarProducts event,
    Emitter<ProductDetailsState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProductDetailsLoaded) {
      // Update state to show loading for similar products
      emit(currentState.copyWith(isSimilarProductsLoading: true));

      final result = await getSimilarProducts(
        GetSimilarProductsParams(productId: event.productId),
      );

      result.fold(
        (failure) {
          // On error, show error state but don't break the main product view
          emit(
            currentState.copyWith(
              isSimilarProductsLoading: false,
              hasSimilarProductsError: true,
              similarProductsErrorMessage: failure.message,
            ),
          );
        },
        (similarProducts) {
          emit(
            currentState.copyWith(
              similarProducts: similarProducts,
              isSimilarProductsLoading: false,
              hasSimilarProductsError: false,
              similarProductsErrorMessage: null,
            ),
          );
        },
      );
    }
  }
}
