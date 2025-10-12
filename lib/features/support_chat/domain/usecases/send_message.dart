import '../repositories/support_chat_repository.dart';

/// Use case: Send a message within an existing support thread.
///
/// This is invoked by the user (customer) when they send a text message,
/// or by an agent when replying from the support dashboard.
///
/// For the customer app, [asAgent] will remain `false`.
class SendMessage {
  final SupportChatRepository repository;

  SendMessage(this.repository);

  /// Executes the use case.
  ///
  /// [threadId] — the UUID of the thread the message belongs to.
  /// [body] — the message text.
  /// [asAgent] — optional; defaults to false for customer messages.
  Future<void> call({
    required String threadId,
    required String body,
    bool asAgent = false,
  }) {
    return repository.sendMessage(
      threadId: threadId,
      body: body,
      asAgent: asAgent,
    );
  }
}
