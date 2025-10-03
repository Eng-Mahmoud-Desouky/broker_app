part of 'home_bloc.dart';

abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

class HomeInitial extends HomeState {}

class HomeLoading extends HomeState {}

class HomeLoaded extends HomeState {
  final List<Offer> offers;
  final List<Platform> platforms;
  final List<Product> suggestedProducts;
  final List<Product>? searchResults;
  final bool isSearching;

  const HomeLoaded({
    required this.offers,
    required this.platforms,
    required this.suggestedProducts,
    this.searchResults,
    this.isSearching = false,
  });

  HomeLoaded copyWith({
    List<Offer>? offers,
    List<Platform>? platforms,
    List<Product>? suggestedProducts,
    List<Product>? searchResults,
    bool? isSearching,
  }) {
    return HomeLoaded(
      offers: offers ?? this.offers,
      platforms: platforms ?? this.platforms,
      suggestedProducts: suggestedProducts ?? this.suggestedProducts,
      searchResults: searchResults ?? this.searchResults,
      isSearching: isSearching ?? this.isSearching,
    );
  }

  @override
  List<Object?> get props => [
        offers,
        platforms,
        suggestedProducts,
        searchResults,
        isSearching,
      ];
}

class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object> get props => [message];
}

class HomeSearching extends HomeState {}

class HomeSearchResults extends HomeState {
  final List<Product> results;
  final String query;

  const HomeSearchResults({
    required this.results,
    required this.query,
  });

  @override
  List<Object> get props => [results, query];
}
