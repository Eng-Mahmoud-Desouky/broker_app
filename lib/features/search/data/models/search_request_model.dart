import '../../domain/entities/search_request.dart';

class SearchRequestModel extends SearchRequest {
  const SearchRequestModel({required super.query, required super.platform});

  Map<String, dynamic> toJson() {
    return {'query': query, 'platform': platform};
  }

  factory SearchRequestModel.fromEntity(SearchRequest request) {
    return SearchRequestModel(query: request.query, platform: request.platform);
  }
}
