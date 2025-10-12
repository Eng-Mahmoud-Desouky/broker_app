import 'package:broker_app/features/support_chat/presentation/widgets/empty_state.dart';
import 'package:broker_app/features/support_chat/presentation/widgets/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/di/injection_container.dart';
import '../../domain/entities/support_message.dart';
import '../bloc/thread/chat_thread_bloc.dart';
import '../widgets/chat_input_bar.dart';
import '../widgets/message_bubble.dart';


class SupportChatPage extends StatelessWidget {
  /// If null → will create/get the current user's active thread via RPC.
  final String? threadId;

  /// Optional subject used when creating a new thread.
  final String? subject;

  /// If you ever reuse this page for agents, set true.
  final bool asAgent;

  const SupportChatPage({
    super.key,
    this.threadId,
    this.subject,
    this.asAgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ChatThreadBloc>()
        ..add(threadId == null
            ? StartThread(subject: subject)
            : SubscribeThread(threadId!)),
      child: const _SupportChatScaffold(),
    );
  }
}

class _SupportChatScaffold extends StatelessWidget {
  const _SupportChatScaffold();

  @override
  Widget build(BuildContext context) {
    return BlocListener<ChatThreadBloc, ChatThreadState>(
      // Act when a thread gets closed: toast + back to threads list
      listenWhen: (_, s) => s is ChatClosed || s is ChatError,
      listener: (context, state) {
        if (state is ChatClosed) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Conversation closed')),
          );
          context.pop(); // Back to threads
        } else if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Back to threads',
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
          title: BlocBuilder<ChatThreadBloc, ChatThreadState>(
            builder: (context, state) {
              final theme = Theme.of(context);
              if (state is ChatReady) {
                final subj = state.thread?.subject?.trim();
                final status = (state.thread?.status ?? 'open').toUpperCase();
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      (subj != null && subj.isNotEmpty)
                          ? subj
                          : 'Support Chat',
                      style: theme.textTheme.titleLarge,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      'Status: $status',
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                );
              }
              return const Text('Support Chat');
            },
          ),
          actions: [
            // Optional: quick info / copy thread id
            const _ThreadInfoButton(),
            // Close thread button (enabled only when ready & not closed)
            Builder(
              builder: (innerCtx) {
                return BlocBuilder<ChatThreadBloc, ChatThreadState>(
                  builder: (context, state) {
                    final enabled = state is ChatReady &&
                        !(state.thread?.isClosed ?? false);
                    return IconButton(
                      tooltip: 'Close thread',
                      icon: const Icon(Icons.check_circle_outline),
                      onPressed: enabled
                          ? () => innerCtx
                          .read<ChatThreadBloc>()
                          .add(const CloseThreadEvent())
                          : null,
                    );
                  },
                );
              },
            ),
          ],
        ),
        body: const _ChatBody(),
      ),
    );
  }
}

class _ChatBody extends StatefulWidget {
  const _ChatBody();

  @override
  State<_ChatBody> createState() => _ChatBodyState();
}

class _ChatBodyState extends State<_ChatBody> {
  final _scroll = ScrollController();

  void _scrollToBottom() {
    if (!_scroll.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scroll.animateTo(
        _scroll.position.maxScrollExtent + 80,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Messages area
        Expanded(
          child: BlocConsumer<ChatThreadBloc, ChatThreadState>(
            listener: (context, state) {
              if (state is ChatReady) _scrollToBottom();
            },
            builder: (context, state) {
              if (state is ChatLoading) {
                return const LoadingIndicator(message: 'Loading chat…');
              }
              if (state is ChatError) {
                return EmptyState(
                  message: state.message,
                  icon: Icons.error_outline,
                );
              }
              if (state is ChatClosed) {
                return const EmptyState(
                  message: 'This conversation is closed.',
                );
              }
              if (state is ChatReady) {
                final messages = state.messages;
                if (messages.isEmpty) {
                  return const EmptyState(message: 'Say hello! 👋');
                }
                final currentUid =
                    Supabase.instance.client.auth.currentUser?.id;
                return ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final msg = messages[i];
                    final isMine = msg.senderId == currentUid;
                    final showDayChip = _shouldShowDayChip(messages, i);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (showDayChip) _DayChip(date: msg.createdAt),
                        MessageBubble(message: msg, isMine: isMine),
                      ],
                    );
                  },
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),

        // Input
        SafeArea(
          top: false,
          child: BlocBuilder<ChatThreadBloc, ChatThreadState>(
            builder: (context, state) {
              final enabled = state is ChatReady &&
                  !(state.thread?.isClosed ?? false);
              return ChatInputBar(
                enabled: enabled,
                onSend: (text) => context
                    .read<ChatThreadBloc>()
                    .add(SendMessageEvent(text, asAgent: false)),
              );
            },
          ),
        ),
      ],
    );
  }

  bool _shouldShowDayChip(List<SupportMessage> messages, int index) {
    if (index == 0) return true;
    final d1 = messages[index - 1].createdAt;
    final d2 = messages[index].createdAt;
    return !(d1.year == d2.year && d1.month == d2.month && d1.day == d2.day);
  }
}

class _DayChip extends StatelessWidget {
  final DateTime date;
  const _DayChip({required this.date});

  @override
  Widget build(BuildContext context) {
    final text = _formatDate(date);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime d) {
    // Example: Fri, Oct 10, 2025
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    const weekdays = [
      'Mon','Tue','Wed','Thu','Fri','Sat','Sun'
    ];
    final wd = weekdays[(d.weekday - 1) % 7];
    final mo = months[d.month - 1];
    return '$wd, $mo ${d.day}, ${d.year}';
  }
}

class _ThreadInfoButton extends StatelessWidget {
  const _ThreadInfoButton();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatThreadBloc, ChatThreadState>(
      builder: (context, state) {
        if (state is! ChatReady) {
          return const SizedBox.shrink();
        }
        return IconButton(
          tooltip: 'Thread info',
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            final thread = state.thread;
            showModalBottomSheet(
              context: context,
              showDragHandle: true,
              builder: (_) => _ThreadInfoSheet(
                threadId: state.threadId,
                subject: thread?.subject,
                status: thread?.status ?? 'open',
              ),
            );
          },
        );
      },
    );
  }
}

class _ThreadInfoSheet extends StatelessWidget {
  final String threadId;
  final String? subject;
  final String status;

  const _ThreadInfoSheet({
    required this.threadId,
    required this.subject,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.tag),
              title: const Text('Thread ID'),
              subtitle: Text(threadId),
              trailing: IconButton(
                tooltip: 'Copy',
                icon: const Icon(Icons.copy_rounded),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: threadId));
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thread ID copied')),
                    );
                  }
                },
              ),
            ),
            ListTile(
              leading: const Icon(Icons.subject),
              title: const Text('Subject'),
              subtitle: Text(
                (subject?.trim().isNotEmpty ?? false)
                    ? subject!
                    : '—',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Status'),
              subtitle: Text(status.toUpperCase()),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.close),
                label: const Text('Dismiss'),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
