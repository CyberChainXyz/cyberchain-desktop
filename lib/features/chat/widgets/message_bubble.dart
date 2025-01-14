import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../utils/avatar_generator.dart';
import 'dart:math' as math;
import '../../../core/theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final bool showName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isMe,
    this.showAvatar = true,
    this.showName = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe && showAvatar)
            AvatarGenerator.buildAvatarFromId(message.avatar, size: 36)
          else if (!isMe)
            const SizedBox(width: 36),
          const SizedBox(width: 8),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth:
                        math.min(MediaQuery.of(context).size.width * 0.75, 500),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(isMe || !showAvatar ? 16 : 4),
                      bottomRight: Radius.circular(isMe && showAvatar ? 4 : 16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isMe && showName)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(
                            message.username,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              color: Color(0xFF2196F3),
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Flexible(
                            child: SelectableText(
                              message.isDeleted
                                  ? 'Message deleted'
                                  : message.content,
                              style: AppTextStyle.withEmojiFonts(
                                TextStyle(
                                  height: 1.4,
                                  color: message.isDeleted
                                      ? const Color(0xFF95A5A6)
                                      : const Color(0xFF2D3843),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: message.isDeleted
                                      ? FontStyle.italic
                                      : FontStyle.normal,
                                  decoration: message.isDeleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                              ),
                              // Enable text selection on desktop
                              enableInteractiveSelection: true,
                              // Optional: customize selection controls
                              toolbarOptions: const ToolbarOptions(
                                copy: true,
                                selectAll: true,
                                cut: false,
                                paste: false,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 1),
                            child: Text(
                              _formatTime(message.createdAt),
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11,
                                color: Color(0xFF8696A9),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isMe) const SizedBox(width: 36),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    // Convert UTC time to local time
    final localTime = time.toLocal();
    final hour = localTime.hour.toString().padLeft(2, '0');
    final minute = localTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
