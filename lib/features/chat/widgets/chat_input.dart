import 'package:flutter/material.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import '../screens/chat_screen.dart';
import 'dart:math' as math;

class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final FocusNode? focusNode;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.focusNode,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> with WidgetsBindingObserver {
  final _textController = TextEditingController();
  late final FocusNode _focusNode;
  bool _canSend = false;
  OverlayEntry? _overlayEntry;
  final _emojiButtonKey = GlobalKey();
  Category _currentCategory = Category.SMILEYS;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _hideEmojiPicker();
    _textController.dispose();
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Do nothing, let parent handle focus
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Do nothing, let parent handle focus
  }

  void _handleSubmitted(String text) {
    if (text.trim().isEmpty) return;
    widget.onSendMessage(text.trim());
    _textController.clear();
    setState(() {
      _canSend = false;
    });
    // Maintain focus after sending
    _focusNode.requestFocus();
  }

  void _switchCategory(Category category) {
    if (_currentCategory != category) {
      setState(() {
        _currentCategory = category;
      });
      // Force rebuild the overlay to update the category
      final currentOverlay = _overlayEntry;
      if (currentOverlay != null) {
        _overlayEntry = null;
        currentOverlay.remove();
        _showEmojiPicker();
      }
    }
  }

  void _showEmojiPicker() {
    if (_overlayEntry != null) return; // Prevent multiple overlays

    final emojiButton =
        _emojiButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    final chatScreen = context.findAncestorStateOfType<State<ChatScreen>>();
    final chatScreenRenderBox =
        chatScreen?.context.findRenderObject() as RenderBox?;

    if (emojiButton == null || overlay == null || chatScreenRenderBox == null)
      return;

    // Get the position relative to chat screen
    final position = emojiButton.localToGlobal(
      Offset.zero,
      ancestor: chatScreenRenderBox,
    );
    final size = emojiButton.size;

    // Calculate width based on number of categories (44px per category)
    final categoriesCount = Category.values.length;
    final pickerWidth = math.max(360.0, categoriesCount * 44.0);

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: size.height + 24,
        left: position.dx,
        child: MouseRegion(
          onExit: (_) => _hideEmojiPicker(),
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 400,
              width: pickerWidth,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(16),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Column(
                  children: [
                    // Emoji grid
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                              ),
                              child: EmojiPicker(
                                onEmojiSelected: (category, emoji) {
                                  _textController.text += emoji.emoji;
                                  setState(() {
                                    _canSend =
                                        _textController.text.trim().isNotEmpty;
                                  });
                                },
                                config: Config(
                                  height: 356,
                                  checkPlatformCompatibility: true,
                                  emojiViewConfig: EmojiViewConfig(
                                    columns: 8,
                                    emojiSizeMax: 28,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    verticalSpacing: 0,
                                    horizontalSpacing: 0,
                                    gridPadding: EdgeInsets.zero,
                                    recentsLimit: 28,
                                    loadingIndicator: const SizedBox.shrink(),
                                    buttonMode: ButtonMode.MATERIAL,
                                  ),
                                  categoryViewConfig: CategoryViewConfig(
                                    backgroundColor:
                                        Theme.of(context).colorScheme.surface,
                                    recentTabBehavior: RecentTabBehavior.RECENT,
                                    initCategory: _currentCategory,
                                    indicatorColor: Colors.transparent,
                                  ),
                                  bottomActionBarConfig:
                                      const BottomActionBarConfig(
                                    showBackspaceButton: false,
                                    showSearchViewButton: false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Custom tab bar
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            height: 44,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.surface,
                                border: Border(
                                  bottom: BorderSide(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline
                                        .withOpacity(0.1),
                                  ),
                                ),
                              ),
                              child: Row(
                                children: Category.values.map((category) {
                                  final isSelected =
                                      category == _currentCategory;
                                  return MouseRegion(
                                    onEnter: (_) => _switchCategory(category),
                                    child: Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: isSelected
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Colors.transparent,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                      child: Icon(
                                        _getCategoryIcon(category),
                                        color: isSelected
                                            ? Theme.of(context)
                                                .colorScheme
                                                .primary
                                            : Theme.of(context)
                                                .colorScheme
                                                .onSurfaceVariant,
                                        size: 24,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _hideEmojiPicker() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  IconData _getCategoryIcon(Category category) {
    switch (category) {
      case Category.RECENT:
        return Icons.access_time;
      case Category.SMILEYS:
        return Icons.emoji_emotions_outlined;
      case Category.ANIMALS:
        return Icons.pets;
      case Category.FOODS:
        return Icons.restaurant;
      case Category.TRAVEL:
        return Icons.travel_explore;
      case Category.ACTIVITIES:
        return Icons.sports_soccer;
      case Category.OBJECTS:
        return Icons.lightbulb_outline;
      case Category.SYMBOLS:
        return Icons.emoji_symbols;
      case Category.FLAGS:
        return Icons.flag_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          MouseRegion(
            onEnter: (_) => _showEmojiPicker(),
            child: IconButton(
              key: _emojiButtonKey,
              onPressed: () {}, // Empty onPressed as we're using hover
              icon: const Icon(Icons.emoji_emotions_outlined),
              color: const Color(0xFF95A5A6),
            ),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE0E0E0),
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                onChanged: (text) {
                  setState(() {
                    _canSend = text.trim().isNotEmpty;
                  });
                },
                onSubmitted: _handleSubmitted,
                decoration: const InputDecoration(
                  hintText: 'Type a message',
                  hintStyle: TextStyle(
                    color: Color(0xFF95A5A6),
                    fontSize: 16,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                ),
                style: const TextStyle(
                  color: Color(0xFF2C3E50),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontFamilyFallback: ['Noto Color Emoji'],
                ),
                textInputAction: TextInputAction.send,
                maxLines: null,
              ),
            ),
          ),
          IconButton(
            onPressed:
                _canSend ? () => _handleSubmitted(_textController.text) : null,
            icon: const Icon(Icons.send),
            color: _canSend
                ? Theme.of(context).colorScheme.primary
                : const Color(0xFF95A5A6),
          ),
        ],
      ),
    );
  }
}
