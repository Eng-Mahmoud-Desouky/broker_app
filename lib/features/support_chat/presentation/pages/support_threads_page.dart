import 'package:broker_app/features/support_chat/domain/repositories/support_chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/support_thread.dart';
import '../bloc/list/chat_list_bloc.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';
import 'support_chat_page.dart';

/// Page that displays a list of support threads.
///
/// - Agents can see all user threads (future expansion).
/// - Users can see their own conversation history.
/// - Each list item navigates to [SupportChatPage].
class SupportThreadsPage extends StatelessWidget {
  final bool forAgent;

  const SupportThreadsPage({super.key, this.forAgent = false});

  @override
  Widget build(BuildContext context) {
    final bloc = sl<ChatListBloc>();
    if (forAgent) {
      bloc.add(const ToggleAgentView(true));
    }

    return BlocProvider(
      create: (_) => bloc..add(const LoadChatThreads()),
      child: Scaffold(
        appBar: AppBar(
          title: Text(forAgent ? 'All Support Threads' : 'My Support Threads'),
          actions: [
            Builder(
              builder: (ctx) => IconButton(
                tooltip: 'Refresh',
                icon: const Icon(Icons.refresh),
                onPressed: () =>
                    ctx.read<ChatListBloc>().add(const RefreshChatThreads()),
              ),
            ),
          ],
        ),
        body: const _ThreadListView(),

        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton.extended(
            icon: const Icon(Icons.add_comment_rounded),
            label: const Text('Start New Chat'),
            onPressed: () async {
              // Ask for an optional subject first
              final subject = await showDialog<String>(
                context: ctx,
                builder: (_) => _NewThreadSubjectDialog(),
              );

              if (subject == null) return;

              try {
                final repo = sl<SupportChatRepository>();
                final thread = await repo.createOrGetMyThread(subject: subject);

                if (ctx.mounted) {
                  context.push('/support/thread/${thread.id}');
                }
              } catch (e) {
                if (ctx.mounted) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text('Failed to create chat: $e')),
                  );
                }
              }
            },
          ),
        ),
      ),
    );
  }
}

/// Builds the thread list and manages search/filter states.
class _ThreadListView extends StatelessWidget {
  const _ThreadListView();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🔍 Search bar
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
          child: TextField(
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search by subject, status, or ID…',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            onChanged: (q) =>
                context.read<ChatListBloc>().add(ApplyThreadSearch(q)),
          ),
        ),

        // 📋 Threads list
        Expanded(
          child: BlocBuilder<ChatListBloc, ChatListState>(
            builder: (context, state) {
              if (state is ChatListLoading) {
                return const LoadingIndicator(message: 'Loading threads…');
              }

              if (state is ChatListError) {
                return EmptyState(
                  message: state.message,
                  icon: Icons.error_outline,
                );
              }

              if (state is ChatListEmpty) {
                return const EmptyState(
                  message: 'No threads found.',
                  icon: Icons.forum_outlined,
                );
              }

              if (state is ChatListLoaded) {
                final threads = state.threads;

                return RefreshIndicator(
                  onRefresh: () async {
                    context
                        .read<ChatListBloc>()
                        .add(const RefreshChatThreads());
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) =>
                        _ThreadTile(thread: threads[i]),
                  ),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ],
    );
  }
}

/// List tile showing summary of a support thread.
class _ThreadTile extends StatelessWidget {
  final SupportThread thread;

  const _ThreadTile({required this.thread});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('yyyy-MM-dd HH:mm');
    final isClosed = thread.status.toLowerCase() == 'closed';

    return ListTile(
      leading: Icon(
        isClosed ? Icons.check_circle_outline : Icons.forum_outlined,
        color: isClosed
            ? Colors.green
            : Theme.of(context).colorScheme.primary,
      ),
      title: Text(
        (thread.subject?.trim().isNotEmpty ?? false)
            ? thread.subject!
            : 'No subject',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        'Status: ${thread.status.toUpperCase()} • '
            'Last: ${df.format(thread.lastMessageAt)}',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        // Navigate to chat page for this thread
        context.push('/support/thread/${thread.id}');
      },
    );
  }
}

class _NewThreadSubjectDialog extends StatefulWidget {
  @override
  State<_NewThreadSubjectDialog> createState() => _NewThreadSubjectDialogState();
}

class _NewThreadSubjectDialogState extends State<_NewThreadSubjectDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thread Subject (optional)'),
      content: TextField(
        controller: _controller,
        decoration: const InputDecoration(
          hintText: 'Example: Payment issue',
          border: OutlineInputBorder(),
        ),
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => Navigator.of(context).pop(_controller.text.trim()),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _controller.text.trim()),
          child: const Text('Start'),
        ),
      ],
    );
  }
}

