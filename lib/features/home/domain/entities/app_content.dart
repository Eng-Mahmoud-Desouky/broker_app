import 'package:equatable/equatable.dart';

class AppContent extends Equatable {
  final String id;
  final String key;
  final String content;

  const AppContent({
    required this.id,
    required this.key,
    required this.content,
  });

  @override
  List<Object?> get props => [id, key, content];
}
