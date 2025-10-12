import '../entities/support_message.dart';
import '../entities/support_thread.dart';

/// Repository contract for the Support Chat feature.
///
/// This abstract class defines the methods available for
/// communicating with customer support via chat.
///
/// Implemented by [SupportChatRepositoryImpl] in the data layer.
///
abstract class SupportChatRepository {
  /// Creates (or fetches) the current user's open thread.
  /// If a non-closed thread already exists, returns it instead of creating a new one.
  Future<SupportThread> createOrGetMyThread({String? subject});

  /// Retrieves all threads for the current user (most recent first).
  Future<List<SupportThread>> listThreadsForMe();

  /// Subscribes to realtime updates for messages in the given thread.
  ///
  /// This stream should emit the full ordered list of messages every time
  /// a new one arrives or is updated.
  Stream<List<SupportMessage>> subscribeMessages(String threadId);

  /// Sends a new message inside a thread.
  ///
  /// For the customer app, [asAgent] will remain `false`.
  /// If this were used in an agent dashboard, `asAgent` would be `true`.
  Future<void> sendMessage({
    required String threadId,
    required String body,
    bool asAgent,
  });

  /// Closes a thread (sets status = 'closed').
  /// RLS allows the owner user or an agent to perform this action.
  Future<void> closeThread(String threadId);
}
