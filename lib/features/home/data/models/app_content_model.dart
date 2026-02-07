import '../../domain/entities/app_content.dart';

class AppContentModel extends AppContent {
  const AppContentModel({
    required super.id,
    required super.key,
    required super.content,
  });

  factory AppContentModel.fromJson(Map<String, dynamic> json) {
    return AppContentModel(
      id: json['id'],
      key: json['key'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'key': key, 'content': content};
  }
}
