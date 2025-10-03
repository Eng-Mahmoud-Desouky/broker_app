part of 'home_bloc.dart';

abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeLoadInitialData extends HomeEvent {
  const HomeLoadInitialData();
}

class HomeRefreshData extends HomeEvent {
  const HomeRefreshData();
}

class HomeSearchProducts extends HomeEvent {
  final String query;

  const HomeSearchProducts({required this.query});

  @override
  List<Object> get props => [query];
}

class HomeSearchProductsByImage extends HomeEvent {
  final String imagePath;

  const HomeSearchProductsByImage({required this.imagePath});

  @override
  List<Object> get props => [imagePath];
}

class HomePlatformSelected extends HomeEvent {
  final Platform platform;

  const HomePlatformSelected({required this.platform});

  @override
  List<Object> get props => [platform];
}

class HomeOfferTapped extends HomeEvent {
  final Offer offer;

  const HomeOfferTapped({required this.offer});

  @override
  List<Object> get props => [offer];
}
