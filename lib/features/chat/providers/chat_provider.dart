import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import '../models/chat_channel.dart';
import '../services/websocket_chat_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
      final response = await http.get(Uri.parse(_channelsUrl));
      if (response.statusCode != 200) {
        throw Exception('Failed to load channels');
      }

      final List<dynamic> channelsJson = jsonDecode(response.body);
      final channels =
          channelsJson.map((json) => ChatChannel.fromJson(json)).toList();

      if (!mounted) return;
      state = state.copyWith(
        channels: channels,
        currentChannel: state.currentChannel ?? channels.first,
      );

      // If we have a current user but no connection, connect to the default channel
      if (state.currentUser != null && !state.isConnected) {
        await switchChannel(state.currentChannel!);
      }
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> switchChannel(ChatChannel channel) async {
    if (!mounted) return;
    try {
      state = state.copyWith(error: null);

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
