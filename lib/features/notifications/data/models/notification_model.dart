import '../../domain/entities/notification.dart';

class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    super.userId,
    required super.title,
    required super.body,
    super.type,
    super.data,
    required super.isRead,
    required super.createdAt,
  });

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      body: json['body'],
      type: json['type'],
      data:
          json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'type': type,
      'data': data,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
