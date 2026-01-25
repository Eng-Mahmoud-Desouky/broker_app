import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/search_request.dart';
import '../../domain/usecases/get_search_url_usecase.dart';

// States
abstract class SearchState extends Equatable {
  const SearchState();

  @override
  List<Object?> get props => [];
}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final String url;

  const SearchLoaded(this.url);

  @override
  List<Object?> get props => [url];
}

class SearchError extends SearchState {
  final String message;

  const SearchError(this.message);

  @override
  List<Object?> get props => [message];
}

// Cubit
class SearchCubit extends Cubit<SearchState> {
  final GetSearchUrlUseCase getSearchUrlUseCase;

  SearchCubit({required this.getSearchUrlUseCase}) : super(SearchInitial());

  Future<void> search(String query, String platform) async {
    if (query.isEmpty) {
      emit(const SearchError("Please enter a search term"));
      return;
    }

    emit(SearchLoading());

    try {
      final request = SearchRequest(query: query, platform: platform);
      final url = await getSearchUrlUseCase(request);
      emit(SearchLoaded(url));
    } catch (e) {
      // Clean up error message if possible
      String message = e.toString();
      if (message.startsWith("Exception: ")) {
        message = message.substring(11);
      }
      emit(SearchError(message));
    }
  }

  void reset() {
    emit(SearchInitial());
  }
}
