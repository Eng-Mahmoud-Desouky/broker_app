import '../entities/search_request.dart';
import '../repositories/search_repository.dart';

class GetSearchUrlUseCase {
  final SearchRepository repository;

  GetSearchUrlUseCase(this.repository);

  Future<String> call(SearchRequest params) async {
    return await repository.getSearchUrl(params);
  }
}
