import 'package:broker_app/features/support_chat/domain/repositories/support_chat_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/support_thread.dart';
import '../bloc/list/chat_list_bloc.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_indicator.dart';

/// Page that displays a list of support threads.
///
/// - Agents can see all user threads (future expansion).
/// - Users can see their own conversation history.
/// - Each list item navigates to the chat route: `/support/thread/:id`.
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
              builder:
                  (ctx) => IconButton(
                    tooltip: 'Refresh',
                    icon: const Icon(Icons.refresh),
                    onPressed:
                        () => ctx.read<ChatListBloc>().add(
                          const RefreshChatThreads(),
                        ),
                  ),
            ),
          ],
        ),

        body: const _ThreadListView(),

        bottomNavigationBar: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Row(
              children: [
                // Start New Chat (outlined)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final subject = await showDialog<String>(
                        context: context,
                        builder: (_) => _NewThreadSubjectDialog(),
                      );
                      if (subject == null) return;

                      try {
                        final repo = sl<SupportChatRepository>();
                        final thread = await repo.createOrGetMyThread(
                          subject: subject,
                        );
                        if (context.mounted) {
                          context.push('/support/thread/${thread.id}');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Failed to create chat: $e'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.add_comment_rounded),
                    label: const Text('Start New Chat'),
                  ),
                ),
                const SizedBox(width: 12),

                // Contact via WhatsApp (elevated green)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final phone = '+201270927868'; // your support number
                      final message = Uri.encodeComponent(
                        'Hello, I need help with the Broker app.',
                      );
                      final url = Uri.parse(
                        'https://wa.me/$phone?text=$message',
                      );

                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Could not open WhatsApp'),
                            ),
                          );
                        }
                      }
                    },
                    icon: const FaIcon(
                      FontAwesomeIcons.whatsapp,
                      color: Colors.white,
                    ),
                    label: const Text('Contact via WhatsApp'),
                  ),
                ),
              ],
            ),
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
            onChanged:
                (q) => context.read<ChatListBloc>().add(ApplyThreadSearch(q)),
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
                    context.read<ChatListBloc>().add(
                      const RefreshChatThreads(),
                    );
                  },
                  color: Theme.of(context).colorScheme.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(12, 6, 12, 12),
                    itemCount: threads.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, i) => _ThreadTile(thread: threads[i]),
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
        color: isClosed ? Colors.green : Theme.of(context).colorScheme.primary,
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
        context.push('/support/thread/${thread.id}');
      },
    );
  }
}

class _NewThreadSubjectDialog extends StatefulWidget {
  @override
  State<_NewThreadSubjectDialog> createState() =>
      _NewThreadSubjectDialogState();
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
