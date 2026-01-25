import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/search_request_model.dart';

abstract class SearchRemoteDataSource {
  Future<String> getSearchUrl(SearchRequestModel request);
}

class SearchRemoteDataSourceImpl implements SearchRemoteDataSource {
  final SupabaseClient supabaseClient;

  SearchRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<String> getSearchUrl(SearchRequestModel request) async {
    try {
      final response = await supabaseClient.functions.invoke(
        'build-search-url',
        body: request.toJson(),
      );

      final data = response.data;

      if (data == null || data['search_url'] == null) {
        throw ServerException(message: 'Invalid response from search service');
      }

      return data['search_url'];
    } catch (e) {
      if (e is FunctionException) {
        throw ServerException(message: e.details?.toString() ?? e.toString());
      }
      throw ServerException(message: e.toString());
    }
  }
}
