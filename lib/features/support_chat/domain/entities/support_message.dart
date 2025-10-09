import 'package:equatable/equatable.dart';

/// Domain entity representing a single message inside a support thread.
///
/// This layer is UI/DB-agnostic (no Supabase/Dart JSON types here).
/// Data layer models should map to/from this entity.
class SupportMessage extends Equatable {
  /// Message UUID.
  final String id;

  /// Parent thread UUID.
  final String threadId;

  /// Sender user UUID (from auth.users).
  final String senderId;

  /// Sender role: 'user' or 'agent'.
  final String sender;

  /// Plain-text body of the message.
  final String body;

  /// Optional attachments metadata (e.g., URLs, mime types).
  final Map<String, dynamic>? attachments;

  /// When the message was created (server time).
  final DateTime createdAt;

  /// When the message was marked as read (nullable).
  final DateTime? readAt;

  const SupportMessage({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.sender,
    required this.body,
    this.attachments,
    required this.createdAt,
    this.readAt,
  });

  /// Convenient immutable update.
  SupportMessage copyWith({
    String? id,
    String? threadId,
    String? senderId,
    String? sender,
    String? body,
    Map<String, dynamic>? attachments,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return SupportMessage(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      senderId: senderId ?? this.senderId,
      sender: sender ?? this.sender,
      body: body ?? this.body,
      attachments: attachments ?? this.attachments,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    threadId,
    senderId,
    sender,
    body,
    attachments,
    createdAt,
    readAt,
  ];
}
