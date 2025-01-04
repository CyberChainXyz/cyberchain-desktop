import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/date_separator.dart';
import '../models/chat_message.dart';
import 'dart:math' as math;

class HexagonPainter extends CustomPainter {
  final Color color;

  HexagonPainter({
    this.color = const Color(0xFF000000),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5
      ..color = color.withOpacity(0.08);

    const double hexSize = 30;
    final double rows = (size.height / (hexSize * 0.866)).ceil().toDouble();
    final double cols = (size.width / hexSize).ceil().toDouble();

    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final xOffset = col * hexSize * 0.75;
        final yOffset = row * hexSize * 0.866;
        final isOffset = row.isOdd;

        final centerX = xOffset + (isOffset ? hexSize * 0.375 : 0);
        final centerY = yOffset;

        final path = Path();
        for (var i = 0; i < 6; i++) {
          final angle = (i * 60 - 30) * math.pi / 180;
          final x = centerX + hexSize * 0.4 * math.cos(angle);
          final y = centerY + hexSize * 0.4 * math.sin(angle);

          if (i == 0) {
            path.moveTo(x, y);
          } else {
            path.lineTo(x, y);
          }
        }
        path.close();
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with WidgetsBindingObserver {
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();
  bool _isInitialBuild = true;
  bool _showScrollToBottom = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scrollController.addListener(_onScroll);
    _scrollToBottom();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInitialBuild && mounted) {
      _isInitialBuild = false;
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Remove auto focus on app lifecycle changes
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Show button if not at bottom (with some threshold)
    final showButton = _scrollController.hasClients &&
        _scrollController.position.pixels <
            _scrollController.position.maxScrollExtent - 200;

    if (showButton != _showScrollToBottom) {
      setState(() {
        _showScrollToBottom = showButton;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  bool _shouldShowAvatar(int index, List<ChatMessage> messages) {
    if (index == messages.length - 1) return true;
    final currentMessage = messages[index];
    final nextMessage = messages[index + 1];

    return currentMessage.senderId != nextMessage.senderId ||
        nextMessage.timestamp.difference(currentMessage.timestamp).inMinutes >
            2;
  }

  bool _shouldShowName(int index, List<ChatMessage> messages) {
    if (index == 0) return true;
    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    return currentMessage.senderId != previousMessage.senderId;
  }

  bool _shouldShowDate(int index, List<ChatMessage> messages) {
    if (index == 0) return true;
    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    final currentDate = DateTime(
      currentMessage.timestamp.year,
      currentMessage.timestamp.month,
      currentMessage.timestamp.day,
    );
    final previousDate = DateTime(
      previousMessage.timestamp.year,
      previousMessage.timestamp.month,
      previousMessage.timestamp.day,
    );

    return currentDate != previousDate;
  }

  void _showRulesDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.info_outline,
              size: 24,
              color: Color(0xFF2196F3),
            ),
            const SizedBox(width: 8),
            Text(
              'Chat Rules & Information',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3843),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Community Rules:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3843),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• No harassment or hate speech\n'
              '• No spam or advertising\n'
              '• No illegal content\n'
              '• Be respectful to others\n'
              '• No personal information sharing',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF2D3843),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Security Information:',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3843),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '• This is an anonymous chat room\n'
              '• Server only caches latest 300 messages\n'
              '• No database storage, no message history\n'
              '• Please be cautious about sharing information\n'
              '• Violations will result in IP ban',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                color: Color(0xFF2D3843),
                height: 1.5,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Got it',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    // Listen to messages changes and scroll to bottom
    ref.listen(chatProvider.select((state) => state.messages),
        (previous, next) {
      if (previous != null && next.length > previous.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _showRulesDialog,
            borderRadius: BorderRadius.circular(4),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFF95A5A6),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Click to view chat rules and information',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Color(0xFF95A5A6),
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        centerTitle: false,
        elevation: 1,
        toolbarHeight: 48,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF9CCC65), // Darker green at top
              Color(0xFFC5E1A5), // Lighter green at bottom
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: HexagonPainter(
                  color: Color(0xFF33691E), // Even darker green for pattern
                ),
              ),
            ),
            Column(
              children: [
                Expanded(
                  child: chatState.messages.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurface
                                    .withOpacity(0.3),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No messages yet',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withOpacity(0.5),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          itemCount: chatState.messages.length,
                          itemBuilder: (context, index) {
                            final message = chatState.messages[index];
                            final isMe =
                                message.senderId == chatState.currentUser?.id;

                            return Column(
                              children: [
                                if (_shouldShowDate(index, chatState.messages))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child:
                                        DateSeparator(date: message.timestamp),
                                  ),
                                MessageBubble(
                                  message: message,
                                  isMe: isMe,
                                  showAvatar: _shouldShowAvatar(
                                      index, chatState.messages),
                                  showName: !isMe &&
                                      _shouldShowName(
                                          index, chatState.messages),
                                ),
                              ],
                            );
                          },
                        ),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        offset: const Offset(0, -1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: ChatInput(
                    focusNode: _focusNode,
                    enabled: chatState.isConnected,
                    onSendMessage: (message) async {
                      await ref
                          .read(chatProvider.notifier)
                          .sendMessage(message);
                    },
                  ),
                ),
              ],
            ),
            if (_showScrollToBottom)
              Positioned(
                right: 16,
                bottom: 80,
                child: Container(
                  height: 36,
                  width: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _scrollToBottom,
                      borderRadius: BorderRadius.circular(18),
                      child: const Icon(
                        Icons.keyboard_arrow_down,
                        size: 20,
                        color: Color(0xFF95A5A6),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
