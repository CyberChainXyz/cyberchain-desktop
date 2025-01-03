import 'package:flutter/material.dart';

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final VoidCallback onEmojiTap;
  final bool showEmojiPicker;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    required this.onEmojiTap,
    required this.showEmojiPicker,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final _textController = TextEditingController();
  bool _canSend = false;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    widget.onSendMessage(text.trim());
    _textController.clear();
    setState(() {
      _canSend = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                widget.showEmojiPicker
                    ? Icons.keyboard
                    : Icons.emoji_emotions_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: widget.onEmojiTap,
            ),
            Expanded(
              child: TextField(
                controller: _textController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type a message',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Theme.of(context).colorScheme.surfaceVariant,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onChanged: (text) {
                  setState(() {
                    _canSend = text.trim().isNotEmpty;
                  });
                },
                onSubmitted: _handleSubmitted,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.send,
                color: _canSend
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface.withOpacity(0.38),
              ),
              onPressed: _canSend
                  ? () => _handleSubmitted(_textController.text)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
