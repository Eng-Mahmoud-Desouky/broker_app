import '../../domain/entities/support_message.dart';
import '../../domain/entities/support_thread.dart';
import '../../domain/repositories/support_chat_repository.dart';
import '../datasources/support_chat_remote_ds.dart';
import '../models/support_message_model.dart';
import '../models/support_thread_model.dart';

/// Implementation of [SupportChatRepository].
///
/// This class delegates all data operations to the [SupportChatRemoteDataSource],
/// and converts between models (data layer) and entities (domain layer).
///
/// For the customer app:
/// - All messages are sent with `sender = 'user'`.
/// - Agents (if implemented) can use the same methods with `asAgent = true`.
class SupportChatRepositoryImpl implements SupportChatRepository {
  final SupportChatRemoteDataSource remote;

  const SupportChatRepositoryImpl({required this.remote});

  @override
  Future<SupportThread> createOrGetMyThread({String? subject}) async {
    final model = await remote.createOrGetMyThread(subject: subject);
    return model.toEntity();
  }

  @override
  Future<List<SupportThread>> listThreadsForMe() async {
    final models = await remote.listThreadsForMe();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Stream<List<SupportMessage>> subscribeMessages(String threadId) {
    return remote.subscribeMessages(threadId).map(
          (models) => models.map((m) => m.toEntity()).toList(),
    );
  }

  @override
  Future<void> sendMessage({
    required String threadId,
    required String body,
    bool asAgent = false,
  }) {
    return remote.sendMessage(threadId: threadId, body: body);
  }

  @override
  Future<void> closeThread(String threadId) {
    return remote.closeThread(threadId);
  }

  // -----------------------------
  // Optional (for agent dashboards)
  // -----------------------------

  Future<List<SupportThread>> listThreadsForAgent() async {
    final models = await remote.listThreadsForAgent();
    return models.map((m) => m.toEntity()).toList();
  }

  Future<void> sendAgentMessage({
    required String threadId,
    required String body,
  }) {
    return remote.sendAgentMessage(threadId: threadId, body: body);
  }
}
