import '../../domain/entities/support_thread.dart';

/// Data model representing a record from `public.support_threads`.
///
/// Used only in the data layer to convert between Supabase response maps
/// (raw JSON rows) and the domain entity [SupportThread].
///
/// Database columns:
/// - id (uuid)
/// - user_id (uuid)
/// - assigned_agent_id (uuid | null)
/// - subject (text | null)
/// - status ('open' | 'pending' | 'closed')
/// - last_message_at (timestamp)
/// - created_at (timestamp)
/// - updated_at (timestamp)
class SupportThreadModel {
  final String id;
  final String userId;
  final String? assignedAgentId;
  final String? subject;
  final String status;
  final DateTime lastMessageAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SupportThreadModel({
    required this.id,
    required this.userId,
    this.assignedAgentId,
    this.subject,
    required this.status,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [SupportThreadModel] from a Supabase map (row).
  factory SupportThreadModel.fromMap(Map<String, dynamic> map) {
    return SupportThreadModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      assignedAgentId: map['assigned_agent_id'] as String?,
      subject: map['subject'] as String?,
      status: map['status'] as String,
      lastMessageAt: DateTime.parse(map['last_message_at'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Converts this model into a plain map (for inserts or updates).
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'assigned_agent_id': assignedAgentId,
      'subject': subject,
      'status': status,
      'last_message_at': lastMessageAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Converts this data model into a domain entity [SupportThread].
  SupportThread toEntity() {
    return SupportThread(
      id: id,
      userId: userId,
      assignedAgentId: assignedAgentId,
      subject: subject,
      status: status,
      lastMessageAt: lastMessageAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [SupportThreadModel] from a domain entity.
  factory SupportThreadModel.fromEntity(SupportThread entity) {
    return SupportThreadModel(
      id: entity.id,
      userId: entity.userId,
      assignedAgentId: entity.assignedAgentId,
      subject: entity.subject,
      status: entity.status,
      lastMessageAt: entity.lastMessageAt,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
