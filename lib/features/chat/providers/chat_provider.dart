import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import '../services/websocket_chat_service.dart';

part 'chat_provider.freezed.dart';

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default(false) bool isConnected,
    @Default(true) bool isLoading,
    @Default([]) List<ChatMessage> messages,
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
          isLoading: true,
        );
        await connect();
      }

      state = state.copyWith(
        isLoading: false,
      );

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

  Future<void> createUser(String name, String avatarId) async {
    if (!mounted) return;
    try {
      state = state.copyWith(isLoading: true, error: null);
      final user = await _chatService.createUser(name, avatarId);
      if (!mounted) return;
      state = state.copyWith(
        currentUser: user,
        isLoading: false,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> connect() async {
    if (!mounted) return;
    try {
      state = state.copyWith(isLoading: true, error: null);
      await _chatService.connect();
      if (!mounted) return;
      state = state.copyWith(
        isConnected: true,
        isLoading: false,
        error: null,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isConnected: false,
        isLoading: false,
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

  Future<void> sendMessage(String content,
      {MessageType type = MessageType.text}) async {
    if (!mounted) return;
    try {
      await _chatService.sendMessage(content, type);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }
}
