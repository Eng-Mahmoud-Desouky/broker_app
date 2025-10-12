
import '../../domain/entities/support_message.dart';

/// Data model representing a message record from `public.support_messages`.
///
/// This class is used only in the data layer to convert between
/// Supabase response maps (raw JSON) and the domain entity [SupportMessage].
///
/// Fields correspond exactly to the database columns:
/// - id (uuid)
/// - thread_id (uuid)
/// - sender_id (uuid)
/// - sender ('user' | 'agent')
/// - body (text)
/// - attachments (jsonb)
/// - created_at (timestamp)
/// - read_at (timestamp | null)
class SupportMessageModel {
  final String id;
  final String threadId;
  final String senderId;
  final String sender; // 'user' or 'agent'
  final String body;
  final Map<String, dynamic>? attachments;
  final DateTime createdAt;
  final DateTime? readAt;

  const SupportMessageModel({
    required this.id,
    required this.threadId,
    required this.senderId,
    required this.sender,
    required this.body,
    this.attachments,
    required this.createdAt,
    this.readAt,
  });

  /// Creates a [SupportMessageModel] from a Supabase map (row).
  factory SupportMessageModel.fromMap(Map<String, dynamic> map) {
    return SupportMessageModel(
      id: map['id'] as String,
      threadId: map['thread_id'] as String,
      senderId: map['sender_id'] as String,
      sender: map['sender'] as String,
      body: map['body'] as String,
      attachments: map['attachments'] != null
          ? Map<String, dynamic>.from(map['attachments'] as Map)
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      readAt: map['read_at'] != null ? DateTime.parse(map['read_at'] as String) : null,
    );
  }

  /// Converts this model into a plain map (for inserts or updates).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'thread_id': threadId,
      'sender_id': senderId,
      'sender': sender,
      'body': body,
      'attachments': attachments,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  /// Converts this data model into the domain entity [SupportMessage].
  SupportMessage toEntity() {
    return SupportMessage(
      id: id,
      threadId: threadId,
      senderId: senderId,
      sender: sender,
      body: body,
      attachments: attachments,
      createdAt: createdAt,
      readAt: readAt,
    );
  }

  /// Creates a [SupportMessageModel] from a domain entity.
  factory SupportMessageModel.fromEntity(SupportMessage entity) {
    return SupportMessageModel(
      id: entity.id,
      threadId: entity.threadId,
      senderId: entity.senderId,
      sender: entity.sender,
      body: entity.body,
      attachments: entity.attachments,
      createdAt: entity.createdAt,
      readAt: entity.readAt,
    );
  }
}
