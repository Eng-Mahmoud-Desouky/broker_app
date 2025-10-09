import '../entities/support_message.dart';
import '../repositories/support_chat_repository.dart';

/// Use case: Subscribe to realtime updates for messages in a given support thread.
///
/// This provides a continuous stream of message lists that the UI (e.g., BLoC)
/// can listen to and rebuild automatically whenever a new message arrives.
///
/// It relies on Supabase Realtime under the hood (handled in the data layer).
class SubscribeMessages {
  final SupportChatRepository repository;

  SubscribeMessages(this.repository);

  /// Executes the use case.
  ///
  /// [threadId] is the UUID of the support thread to listen to.
  /// Returns a stream that emits the **full ordered list** of messages.
  Stream<List<SupportMessage>> call(String threadId) {
    return repository.subscribeMessages(threadId);
  }
}
