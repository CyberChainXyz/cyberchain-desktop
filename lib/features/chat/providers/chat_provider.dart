import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import '../models/chat_channel.dart';
import '../services/websocket_chat_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/utils/custom_http_client.dart';

part 'chat_provider.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default(false) bool isConnected,
    @Default(true) bool isLoading,
    @Default([]) List<ChatMessage> messages,
    @Default([]) List<ChatChannel> channels,
    ChatChannel? currentChannel,
    ChatUser? currentUser,
    String? error,
  }) = _ChatState;
}

// Single instance of WebSocketChatService
final _chatService = WebSocketChatService();

final chatServiceProvider = Provider<WebSocketChatService>((ref) {
  return _chatService;
});

final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(_chatService);
});

class ChatNotifier extends StateNotifier<ChatState> {
  final WebSocketChatService _chatService;
  StreamSubscription<ChatMessage>? _messageSubscription;
  StreamSubscription<List<ChatMessage>>? _initialMessagesSubscription;
  bool _initialized = false;
  static const String _channelsUrl = 'https://chat.cyberchain.xyz/api/channels';
  static const bool _useHardcodedChannels = true;
  static const String _lastChannelIdKey = 'last_channel_id';

  static final List<ChatChannel> _hardcodedChannels = [
    ChatChannel(
      id: "de813c0f11d0f1521450ee4389674dda",
      name: "🇬🇧 English",
      description: "English",
      createdAt: DateTime.parse("2025-01-05T17:37:56.011282265Z"),
    ),
    ChatChannel(
      id: "7972861142c885cbb504b15e0a69c5d1",
      name: "🇨🇳 中文",
      description: "中文",
      createdAt: DateTime.parse("2025-01-05T17:38:28.047464787Z"),
    ),
    ChatChannel(
      id: "83a8f8ae4dc57214e75388e23aa5b0c5",
      name: "🇯🇵 日本語",
      description: "日本語",
      createdAt: DateTime.parse("2025-01-05T17:40:18.705806467Z"),
    ),
    ChatChannel(
      id: "30223d83427bcced40f7729cb5d12268",
      name: "🇰🇷 한국어",
      description: "한국어",
      createdAt: DateTime.parse("2025-01-05T17:40:33.485538907Z"),
    ),
    ChatChannel(
      id: "23c2f8fb428d8c9f00b18905c474b201",
      name: "🇷🇺 Русский",
      description: "Русский",
      createdAt: DateTime.parse("2025-01-05T17:41:00.252942044Z"),
    ),
    ChatChannel(
      id: "0d7d717bacd333c0fc1b6de87d3541eb",
      name: "🇫🇷 Français",
      description: "Français",
      createdAt: DateTime.parse("2025-01-05T17:41:31.088885656Z"),
    ),
    ChatChannel(
      id: "f2d5b468c640cb645aaf125eca9bef0b",
      name: "🇩🇪 Deutsch",
      description: "Deutsch",
      createdAt: DateTime.parse("2025-01-05T17:41:52.333074516Z"),
    ),
    ChatChannel(
      id: "7cce01891e8463391101df69391b3ec7",
      name: "🇪🇸 Español",
      description: "Español",
      createdAt: DateTime.parse("2025-01-05T17:39:41.201169849Z"),
    ),
  ];

  ChatNotifier(this._chatService)
      : super(ChatState(
          isLoading: true,
          currentUser: null,
          isConnected: false,
        )) {
    _init();
  }

  Future<void> _init() async {
    if (!mounted || _initialized) return;
    _initialized = true;

    try {
      await _chatService.initialized;
      final user = _chatService.currentUser;
      if (!mounted) return;

      if (user != null) {
        state = state.copyWith(
          currentUser: user,
          isLoading: false,
        );
        // Only load channels without connecting
        await loadChannels();
      } else {
        state = state.copyWith(
          isLoading: false,
        );
      }

      _setupSubscriptions();
      _monitorConnection();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadChannels() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastChannelId = prefs.getString(_lastChannelIdKey);

      if (_useHardcodedChannels) {
        if (!mounted) return;

        // Find last used channel or default to first channel
        ChatChannel? lastChannel;
        if (lastChannelId != null) {
          lastChannel = _hardcodedChannels.firstWhere(
            (c) => c.id == lastChannelId,
            orElse: () => _hardcodedChannels.first,
          );
        }

        state = state.copyWith(
          channels: _hardcodedChannels,
          currentChannel: lastChannel ?? _hardcodedChannels.first,
        );
        return;
      }

      final response = await getClient().get(Uri.parse(_channelsUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load channels');
      }

      final List<dynamic> channelsJson = jsonDecode(response.body);
      final channels =
          channelsJson.map((json) => ChatChannel.fromJson(json)).toList();

      if (!mounted) return;

      // Find last used channel or default to first channel
      ChatChannel? lastChannel;
      if (lastChannelId != null) {
        lastChannel = channels.firstWhere(
          (c) => c.id == lastChannelId,
          orElse: () => channels.first,
        );
      }

      state = state.copyWith(
        channels: channels,
        currentChannel: lastChannel ?? channels.first,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> switchChannel(ChatChannel channel) async {
    if (!mounted) return;
    try {
      state = state.copyWith(error: null);

      // Save selected channel ID
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastChannelIdKey, channel.id);

      // Disconnect from current channel if connected
      if (state.isConnected) {
        await disconnect();
      }

      // Update current channel
      state = state.copyWith(
        currentChannel: channel,
        messages: [], // Clear messages when switching channels
      );

      // Connect to new channel
      await _chatService.connect(channelId: channel.id);

      if (!mounted) return;
      state = state.copyWith(
        isConnected: true,
        error: null,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isConnected: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  void _monitorConnection() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      final isConnected = _chatService.isConnected;
      if (state.isConnected != isConnected) {
        state = state.copyWith(isConnected: isConnected);
      }
    });
  }

  void _setupSubscriptions() {
    _messageSubscription?.cancel();
    _initialMessagesSubscription?.cancel();

    _messageSubscription = _chatService.messageStream.listen(
      (message) {
        if (!mounted) return;
        final messages = [...state.messages];
        if (!messages.any((m) => m.id == message.id)) {
          state = state.copyWith(messages: [...messages, message]);
        }
      },
    );

    _initialMessagesSubscription = _chatService.initialMessages.listen(
      (messages) {
        if (!mounted) return;
        state = state.copyWith(messages: messages);
      },
    );
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    _initialMessagesSubscription?.cancel();
    (_chatService as WebSocketChatService).dispose();
    super.dispose();
  }

  Future<void> createUser(String username, String avatar) async {
    if (!mounted) return;
    try {
      state = state.copyWith(error: null);
      final user = await _chatService.createUser(username, avatar);
      if (!mounted) return;
      state = state.copyWith(
        currentUser: user,
      );
      await loadChannels();
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> connect() async {
    if (!mounted || state.currentChannel == null) return;
    try {
      state = state.copyWith(error: null);
      await _chatService.connect(channelId: state.currentChannel!.id);
      if (!mounted) return;
      state = state.copyWith(
        isConnected: true,
        error: null,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isConnected: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> disconnect() async {
    if (!mounted) return;
    await _chatService.disconnect();
    state = state.copyWith(isConnected: false);
  }

  Future<void> sendMessage(String content) async {
    if (!mounted) return;
    try {
      await _chatService.sendMessage(content);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}
