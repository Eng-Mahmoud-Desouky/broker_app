import 'package:broker_app/features/support_chat/domain/entities/support_message.dart';
import 'package:flutter/material.dart';

/// A single chat message bubble used in the Support Chat screen.
///
/// - Aligns to the right for the current user's messages.
/// - Aligns to the left for agent messages.
/// - Displays message text, optional attachments, and timestamp.
class MessageBubble extends StatelessWidget {
  final SupportMessage message;
  final bool isMine;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        constraints: const BoxConstraints(maxWidth: 320),
        decoration: BoxDecoration(
          color: isMine
              ? theme.colorScheme.primary
              : theme.colorScheme.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(12),
            topRight: const Radius.circular(12),
            bottomLeft: Radius.circular(isMine ? 12 : 0),
            bottomRight: Radius.circular(isMine ? 0 : 12),
          ),
        ),
        child: Column(
          crossAxisAlignment:
          isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // 📝 Message text
            Text(
              message.body,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isMine
                    ? Colors.white
                    : theme.colorScheme.onSurfaceVariant,
              ),
            ),

            // 📎 Attachments preview (future use)
            if (message.attachments != null &&
                message.attachments!.isNotEmpty) ...[
              const SizedBox(height: 6),
              _AttachmentPreview(attachments: message.attachments!),
            ],

            // 🕒 Timestamp
            const SizedBox(height: 4),
            Text(
              _formatTime(message.createdAt),
              style: theme.textTheme.labelSmall?.copyWith(
                color: isMine
                    ? Colors.white70
                    : theme.colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Formats time as HH:mm (24-hour).
  static String _formatTime(DateTime time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Small horizontal preview row for message attachments (if any).
class _AttachmentPreview extends StatelessWidget {
  final Map<String, dynamic> attachments;
  const _AttachmentPreview({required this.attachments});

  @override
  Widget build(BuildContext context) {
    // You can adapt this later for actual attachments (images, files, etc.)
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.05),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '📎 Attachment (${attachments.length})',
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}
