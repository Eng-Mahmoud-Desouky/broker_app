import '../entities/support_thread.dart';
import '../repositories/support_chat_repository.dart';

/// Use case: Create (or fetch) the current user's active support thread.
///
/// If the user already has an open or pending thread, it returns that one.
/// Otherwise, it creates a new thread in Supabase via RPC.
///
/// This use case belongs to the domain layer and is
/// independent of Flutter, Supabase, or BLoC implementations.
class CreateOrGetThread {
  final SupportChatRepository repository;

  CreateOrGetThread(this.repository);

  /// Executes the use case.
  ///
  /// [subject] is optional; it can be used when the user initiates
  /// a support conversation with a specific topic.
  Future<SupportThread> call({String? subject}) {
    return repository.createOrGetMyThread(subject: subject);
  }
}
