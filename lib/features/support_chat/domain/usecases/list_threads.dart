import '../entities/support_thread.dart';
import '../repositories/support_chat_repository.dart';

/// Use case: Retrieve all support threads for the current user.
///
/// For customers, this returns only the threads they created.
/// For support agents (if RLS allows), this could be extended
/// to return all threads in the system.
class ListThreads {
  final SupportChatRepository repository;

  ListThreads(this.repository);

  /// Executes the use case.
  ///
  /// Returns a list of [SupportThread] objects ordered by
  /// `last_message_at` (most recent first).
  Future<List<SupportThread>> call() {
    return repository.listThreadsForMe();
  }
}
