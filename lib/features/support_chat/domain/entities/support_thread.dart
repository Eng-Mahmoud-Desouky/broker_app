import 'package:equatable/equatable.dart';

/// Domain entity representing a support conversation (thread)
/// between a user and customer support.
///
/// This entity is independent from any database or UI code.
/// Data models (e.g., [SupportThreadModel]) map to/from this class.
///
/// Matches columns from `public.support_threads`:
/// - id (uuid)
/// - user_id (uuid)
/// - assigned_agent_id (uuid | null)
/// - subject (text | null)
/// - status ('open' | 'pending' | 'closed')
/// - last_message_at (timestamp)
/// - created_at (timestamp)
/// - updated_at (timestamp)
class SupportThread extends Equatable {
  /// Thread UUID.
  final String id;

  /// The user who created this support thread.
  final String userId;

  /// The agent currently assigned to this thread (nullable).
  final String? assignedAgentId;

  /// Optional subject or title for the conversation.
  final String? subject;

  /// Current thread status: 'open', 'pending', or 'closed'.
  final String status;

  /// Last time a message was sent in this thread.
  final DateTime lastMessageAt;

  /// Thread creation timestamp.
  final DateTime createdAt;

  /// Last updated timestamp.
  final DateTime updatedAt;

  const SupportThread({
    required this.id,
    required this.userId,
    this.assignedAgentId,
    this.subject,
    required this.status,
    required this.lastMessageAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Returns `true` if the thread is closed.
  bool get isClosed => status.toLowerCase() == 'closed';

  /// Returns `true` if this thread has been assigned to an agent.
  bool get hasAgent => assignedAgentId != null;

  /// Creates a copy with selective updates (immutable pattern).
  SupportThread copyWith({
    String? id,
    String? userId,
    String? assignedAgentId,
    String? subject,
    String? status,
    DateTime? lastMessageAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SupportThread(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      assignedAgentId: assignedAgentId ?? this.assignedAgentId,
      subject: subject ?? this.subject,
      status: status ?? this.status,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    userId,
    assignedAgentId,
    subject,
    status,
    lastMessageAt,
    createdAt,
    updatedAt,
  ];
}
