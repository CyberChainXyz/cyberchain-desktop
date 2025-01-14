import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import 'chat_service.dart';
import '../../../core/utils/custom_http_client.dart';
import '../../../core/utils/user_agent_utils.dart';
import 'package:flutter/foundation.dart';

class WebSocketChatService implements ChatService {
  static const String _productionBaseUrl = 'https://chat.cyberchain.xyz';
  static const String _debugBaseUrl = 'http://127.0.0.1:8080';
  static const String _productionWsUrlTemplate =
      'wss://chat.cyberchain.xyz/ws/{channel_id}';
  static const String _debugWsUrlTemplate =
      'ws://127.0.0.1:8080/ws/{channel_id}';

  static String get _baseUrl => kDebugMode ? _debugBaseUrl : _productionBaseUrl;
  static String get _wsUrlTemplate =>
      kDebugMode ? _debugWsUrlTemplate : _productionWsUrlTemplate;
  static const String _productionUserKey = 'chat_user';
  static const String _debugUserKey = 'debug_chat_user';
  static const String _userKey =
      kDebugMode ? _debugUserKey : _productionUserKey;
  static const Duration _retryInterval = Duration(seconds: 3);

  String _getWsUrl(String channelId) =>
      _wsUrlTemplate.replaceAll('{channel_id}', channelId);

  WebSocketChannel? _channel;
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _initialMessagesController =
      StreamController<List<ChatMessage>>.broadcast();
  ChatUser? _currentUser;
  bool _isConnected = false;
  bool _isConnecting = false;
  Timer? _reconnectTimer;
  final Completer<void> _initCompleter = Completer<void>();
  bool _isDisposed = false;
  String? _currentChannelId;

  WebSocketChatService() {
    _loadSavedUser();
  }

  Future<void> get initialized => _initCompleter.future;

  Future<void> _loadSavedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_userKey);
      if (userJson != null) {
        _currentUser = ChatUser.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      // Error handling
    } finally {
      _initCompleter.complete();
    }
  }

  Future<void> _saveUser(ChatUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
    } catch (e) {
      // Error handling
    }
  }

  @override
  bool get isConnected => _isConnected;

  @override
  ChatUser? get currentUser => _currentUser;

  @override
  Future<ChatUser> createUser(String name, String avatarId) async {
    try {
      final client = getClient();
      try {
        final response = await client.post(
          Uri.parse('$_baseUrl/api/users'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'username': name,
            'avatar': avatarId,
          }),
        );

        if (response.statusCode != 200) {
          throw Exception(
              'Failed to create user: ${response.statusCode} - ${response.body}');
        }

        final responseData = jsonDecode(response.body) as Map<String, dynamic>;
        _currentUser = ChatUser.fromJson(responseData);
        await _saveUser(_currentUser!);
        return _currentUser!;
      } finally {
        client.close();
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> connect({required String channelId}) async {
    if (_currentUser == null) {
      throw Exception('User not created');
    }

    if (_isConnected || _isConnecting) {
      return;
    }

    _isConnecting = true;
    _currentChannelId = channelId;
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(_getWsUrl(channelId)),
        protocols: [
          _currentUser!.id,
          _currentUser!.secretKey,
          UserAgentUtils.getUserAgent(),
        ],
      );

      // Wait for the connection to be established
      await _channel!.ready;

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['type'] == 'initial_messages') {
            final messages = (data['messages'] as List)
                .map((m) => ChatMessage.fromJson(m))
                .toList();
            _initialMessagesController.add(messages);
          } else {
            _messageController.add(ChatMessage.fromJson(data));
          }
        },
        onDone: () {
          _handleDisconnection();
        },
        onError: (error, stackTrace) {
          _handleDisconnection();
        },
        cancelOnError: false,
      );

      _isConnected = true;
      _stopReconnectTimer();
    } catch (e) {
      _handleDisconnection();
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  void _handleDisconnection() {
    if (_isDisposed) return;

    _isConnected = false;
    _channel?.sink.close();
    _channel = null;

    if (_reconnectTimer == null || !_reconnectTimer!.isActive) {
      _startReconnectTimer();
    }
  }

  void _startReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer.periodic(_retryInterval, (timer) async {
      if (_isConnected || _isDisposed || _currentChannelId == null) {
        _stopReconnectTimer();
        return;
      }

      try {
        await connect(channelId: _currentChannelId!);
      } catch (e) {
        // ignore
      }
    });
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  @override
  Future<void> disconnect() async {
    _stopReconnectTimer();
    await _channel?.sink.close();
    _isConnected = false;
    _currentChannelId = null;
  }

  void dispose() {
    _isDisposed = true;
    _stopReconnectTimer();
    disconnect();
    _messageController.close();
    _initialMessagesController.close();
  }

  @override
  Future<void> sendMessage(String content) async {
    if (!_isConnected || _currentUser == null) {
      throw Exception('Not connected');
    }

    _channel!.sink.add(content);
  }

  @override
  Stream<ChatMessage> get messageStream => _messageController.stream;

  @override
  Stream<List<ChatMessage>> get initialMessages =>
      _initialMessagesController.stream;
}
