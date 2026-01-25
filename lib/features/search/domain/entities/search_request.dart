import 'package:equatable/equatable.dart';

class SearchRequest extends Equatable {
  final String query;
  final String platform;

  const SearchRequest({required this.query, required this.platform});

  @override
  List<Object> get props => [query, platform];
}
