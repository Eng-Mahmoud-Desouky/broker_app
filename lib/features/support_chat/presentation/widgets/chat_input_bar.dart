import 'package:flutter/material.dart';

/// Compact message input bar for the support chat screen.
///
/// Features:
/// - Multiline TextField (auto-expands up to 5 lines)
/// - Disabled state (e.g., when thread is closed or loading)
/// - Sends on "Enter" (mobile submit) and on send button tap
/// - Optional attachment button callback
class ChatInputBar extends StatefulWidget {
  final bool enabled;
  final void Function(String text) onSend;
  final VoidCallback? onAttach; // optional

  const ChatInputBar({
    super.key,
    required this.enabled,
    required this.onSend,
    this.onAttach,
  });

  @override
  State<ChatInputBar> createState() => _ChatInputBarState();
}

class _ChatInputBarState extends State<ChatInputBar> {
  final _controller = TextEditingController();
  final _focus = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!widget.enabled) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    widget.onSend(text);
    _controller.clear();
    _focus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final disabled = !widget.enabled;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Row(
        children: [
          // Attachment (optional)
          if (widget.onAttach != null)
            IconButton(
              tooltip: 'Attach',
              icon: const Icon(Icons.attach_file_rounded),
              onPressed: disabled ? null : widget.onAttach,
            ),

          // Text field
          Expanded(
            child: IgnorePointer(
              ignoring: disabled,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: disabled ? 0.6 : 1,
                child: TextField(
                  controller: _controller,
                  focusNode: _focus,
                  textInputAction: TextInputAction.newline,
                  minLines: 1,
                  maxLines: 5,
                  onSubmitted: (_) => _submit(),
                  decoration: InputDecoration(
                    hintText:
                    disabled ? 'Thread is closed' : 'Type your message…',
                    isDense: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    fillColor: theme.colorScheme.surface,
                    filled: true,
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Send button
          SizedBox(
            height: 44,
            width: 44,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: const CircleBorder(),
              ),
              onPressed: disabled ? null : _submit,
              child: const Icon(Icons.send_rounded, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}