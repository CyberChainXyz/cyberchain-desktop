import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/chat_provider.dart';
import '../widgets/message_bubble.dart';
import '../widgets/chat_input.dart';
import '../widgets/date_separator.dart';
import '../widgets/notification_marquee.dart';
import '../models/chat_message.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/app_notification_service.dart';

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

    final path = Path();
    for (var row = 0; row < rows; row++) {
      for (var col = 0; col < cols; col++) {
        final xOffset = col * hexSize * 0.75;
        final yOffset = row * hexSize * 0.866;
        final isOffset = row.isOdd;

        final centerX = xOffset + (isOffset ? hexSize * 0.375 : 0);
        final centerY = yOffset;

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
      }
    }
    canvas.drawPath(path, paint);
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

    // Initialize WebSocket connection
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatState = ref.read(chatProvider);
      final chatNotifier = ref.read(chatProvider.notifier);
      if (chatState.currentUser != null && !chatState.isConnected) {
        chatNotifier.connect();
      }
    });
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

    return currentMessage.userId != nextMessage.userId ||
        nextMessage.createdAt.difference(currentMessage.createdAt).inMinutes >
            2;
  }

  bool _shouldShowName(int index, List<ChatMessage> messages) {
    if (index == 0) return true;
    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    return currentMessage.userId != previousMessage.userId;
  }

  bool _shouldShowDate(int index, List<ChatMessage> messages) {
    if (index == 0) return true;
    final currentMessage = messages[index];
    final previousMessage = messages[index - 1];

    final currentDate = DateTime(
      currentMessage.createdAt.toLocal().year,
      currentMessage.createdAt.toLocal().month,
      currentMessage.createdAt.toLocal().day,
    );
    final previousDate = DateTime(
      previousMessage.createdAt.toLocal().year,
      previousMessage.createdAt.toLocal().month,
      previousMessage.createdAt.toLocal().day,
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

  void _showChannelSelectionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.language,
              size: 24,
              color: Color(0xFF2196F3),
            ),
            const SizedBox(width: 8),
            Text(
              'Select Language Channel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3843),
              ),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(8, 20, 8, 24),
        content: SizedBox(
          width: 300,
          child: Consumer(
            builder: (context, ref, _) {
              final chatState = ref.watch(chatProvider);
              return ListView.builder(
                shrinkWrap: true,
                itemCount: chatState.channels.length,
                itemBuilder: (context, index) {
                  final channel = chatState.channels[index];
                  final isSelected = channel.id == chatState.currentChannel?.id;
                  return Material(
                    color: Colors.transparent,
                    child: ListTile(
                      dense: true,
                      onTap: () {
                        ref.read(chatProvider.notifier).switchChannel(channel);
                        Navigator.of(context).pop();
                      },
                      selected: isSelected,
                      selectedTileColor: Color(0xFF2196F3).withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      title: Text(
                        channel.name,
                        style: AppTextStyle.withEmojiFonts(
                          TextStyle(
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? Color(0xFF2196F3)
                                : Color(0xFF2D3843),
                          ),
                        ),
                      ),
                      leading: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: Color(0xFF2196F3),
                              size: 20,
                            )
                          : SizedBox(width: 20),
                    ),
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF95A5A6),
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
        title: Row(
          children: [
            Text(
              chatState.currentChannel?.name ?? '',
              style: AppTextStyle.withEmojiFonts(
                const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF2D3843),
                ),
              ),
            ),
            if (!chatState.isConnected)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.error,
                    ),
                  ),
                ),
              ),
            const SizedBox(width: 16),
            const Expanded(
              child: NotificationMarquee(),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 1,
        toolbarHeight: 48,
        actions: [
          Consumer(
            builder: (context, ref, _) {
              final isEnabled = ref.watch(notificationSettingsProvider);
              return IconButton(
                icon: Icon(
                  isEnabled
                      ? Icons.notifications_active
                      : Icons.notifications_off,
                  size: 20,
                  color: isEnabled
                      ? const Color(0xFF2196F3)
                      : const Color(0xFF95A5A6),
                ),
                onPressed: () =>
                    ref.read(notificationSettingsProvider.notifier).toggle(),
                tooltip: isEnabled
                    ? 'Disable Notifications'
                    : 'Enable Notifications',
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.language,
              size: 20,
              color: Color(0xFF95A5A6),
            ),
            onPressed: () => _showChannelSelectionDialog(),
            tooltip: 'Select Language Channel',
          ),
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              size: 20,
              color: Color(0xFF95A5A6),
            ),
            onPressed: _showRulesDialog,
            tooltip: 'Chat Rules',
          ),
          IconButton(
            icon: const Icon(
              Icons.help_outline,
              size: 20,
              color: Color(0xFF95A5A6),
            ),
            onPressed: () {
              launchUrl(
                Uri.parse('https://github.com/orgs/CyberChainXyz/discussions'),
                mode: LaunchMode.externalApplication,
              );
            },
            tooltip: 'Community Discussions',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF9CCC65),
              Color(0xFFC5E1A5),
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: HexagonPainter(
                    color: Color(0xFF33691E),
                  ),
                ),
              ),
            ),
            if (!chatState.isConnected && 0 == 1)
              Positioned(
                top: 8,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.red.shade100,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.red.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red.shade700),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Reconnecting to chat...',
                          style: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
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
                                message.userId == chatState.currentUser?.id;

                            return Column(
                              children: [
                                if (_shouldShowDate(index, chatState.messages))
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child:
                                        DateSeparator(date: message.createdAt),
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
