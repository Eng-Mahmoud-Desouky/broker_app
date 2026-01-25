import '../entities/search_request.dart';

abstract class SearchRepository {
  Future<String> getSearchUrl(SearchRequest request);
}
