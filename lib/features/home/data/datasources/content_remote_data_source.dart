import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/error/exceptions.dart';
import '../models/app_content_model.dart';

abstract class ContentRemoteDataSource {
  Future<AppContentModel> getAppContent(String key);
}

class ContentRemoteDataSourceImpl implements ContentRemoteDataSource {
  final SupabaseClient supabaseClient;

  ContentRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<AppContentModel> getAppContent(String key) async {
    try {
      final response =
          await supabaseClient
              .from('app_content')
              .select()
              .eq('key', key)
              .single();

      return AppContentModel.fromJson(response);
    } catch (e) {
      print('❌ Error fetching content for key: $key');
      print('❌ Error details: $e');
      throw ServerException(message: 'Failed to fetch content: $e');
    }
  }
}
