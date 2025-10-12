import '../repositories/support_chat_repository.dart';

/// Use case: Close an existing support thread.
///
/// Sets the thread's status to `'closed'` in the database.
/// Only the thread owner or a support agent (based on RLS) can perform this action.
class CloseThread {
  final SupportChatRepository repository;

  CloseThread(this.repository);

  /// Executes the use case.
  ///
  /// [threadId] — the UUID of the thread to be closed.
  Future<void> call(String threadId) {
    return repository.closeThread(threadId);
  }
}
