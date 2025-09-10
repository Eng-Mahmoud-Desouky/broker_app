import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/offer.dart';
import '../../domain/entities/platform.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/get_featured_offers.dart';
import '../../domain/usecases/get_platforms.dart';
import '../../domain/usecases/get_suggested_products.dart';
import '../../domain/usecases/search_products.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final GetFeaturedOffers getFeaturedOffers;
  final GetPlatforms getPlatforms;
  final GetSuggestedProducts getSuggestedProducts;
  final SearchProducts searchProducts;

  HomeBloc({
    required this.getFeaturedOffers,
    required this.getPlatforms,
    required this.getSuggestedProducts,
    required this.searchProducts,
  }) : super(HomeInitial()) {
    on<HomeLoadInitialData>(_onLoadInitialData);
    on<HomeRefreshData>(_onRefreshData);
    on<HomeSearchProducts>(_onSearchProducts);
    on<HomeSearchProductsByImage>(_onSearchProductsByImage);
    on<HomePlatformSelected>(_onPlatformSelected);
    on<HomeOfferTapped>(_onOfferTapped);
  }

  Future<void> _onLoadInitialData(
    HomeLoadInitialData event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());
    await _loadHomeData(emit);
  }

  Future<void> _onRefreshData(
    HomeRefreshData event,
    Emitter<HomeState> emit,
  ) async {
    await _loadHomeData(emit);
  }

  Future<void> _loadHomeData(Emitter<HomeState> emit) async {
    try {
      // Load all data concurrently
      final results = await Future.wait([
        getFeaturedOffers(NoParams()),
        getPlatforms(NoParams()),
        getSuggestedProducts(NoParams()),
      ]);

      final offersResult = results[0];
      final platformsResult = results[1];
      final productsResult = results[2];

      // Check if any request failed
      if (offersResult.isLeft() ||
          platformsResult.isLeft() ||
          productsResult.isLeft()) {
        emit(const HomeError(message: 'فشل في تحميل البيانات'));
        return;
      }

      // Extract successful results
      final offers = offersResult.fold(
        (l) => <Offer>[],
        (r) => r as List<Offer>,
      );
      final platforms = platformsResult.fold(
        (l) => <Platform>[],
        (r) => r as List<Platform>,
      );
      final products = productsResult.fold(
        (l) => <Product>[],
        (r) => r as List<Product>,
      );

      emit(
        HomeLoaded(
          offers: offers,
          platforms: platforms,
          suggestedProducts: products,
        ),
      );
    } catch (e) {
      emit(HomeError(message: 'حدث خطأ غير متوقع: ${e.toString()}'));
    }
  }

  Future<void> _onSearchProducts(
    HomeSearchProducts event,
    Emitter<HomeState> emit,
  ) async {
    if (event.query.trim().isEmpty) {
      // If query is empty, return to normal state
      if (state is HomeLoaded) {
        emit(
          (state as HomeLoaded).copyWith(
            searchResults: null,
            isSearching: false,
          ),
        );
      }
      return;
    }

    emit(HomeSearching());

    final result = await searchProducts(
      SearchProductsParams(query: event.query),
    );

    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (products) =>
          emit(HomeSearchResults(results: products, query: event.query)),
    );
  }

  Future<void> _onSearchProductsByImage(
    HomeSearchProductsByImage event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeSearching());

    // Placeholder implementation - for now just return suggested products
    final result = await getSuggestedProducts(NoParams());

    result.fold(
      (failure) => emit(HomeError(message: failure.message)),
      (products) =>
          emit(HomeSearchResults(results: products, query: 'البحث بالصورة')),
    );
  }

  void _onPlatformSelected(
    HomePlatformSelected event,
    Emitter<HomeState> emit,
  ) {
    // This will be handled by navigation in the UI
    // For now, we just acknowledge the event
  }

  void _onOfferTapped(HomeOfferTapped event, Emitter<HomeState> emit) {
    // This will be handled by navigation in the UI
    // For now, we just acknowledge the event
  }
}
