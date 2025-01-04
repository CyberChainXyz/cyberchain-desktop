import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import 'chat_service.dart';

class WebSocketChatService implements ChatService {
  static const String _baseUrl = 'http://localhost:8080';
  static const String _wsUrl = 'ws://localhost:8080/ws/chat';
  static const String _userKey = 'chat_user';
  static const Duration _retryInterval = Duration(seconds: 3);

  WebSocketChannel? _channel;
  final _messageController = StreamController<ChatMessage>.broadcast();
  final _initialMessagesController =
      StreamController<List<ChatMessage>>.broadcast();
  ChatUser? _currentUser;
  bool _isConnected = false;
  Timer? _reconnectTimer;
  final Completer<void> _initCompleter = Completer<void>();
  bool _isDisposed = false;

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
        developer.log('Loaded saved user: ${_currentUser!.id}');
        // Automatically connect if we have a saved user
        await connect();
      }
    } catch (e) {
      developer.log('Error loading saved user: $e', error: e);
    } finally {
      _initCompleter.complete();
    }
  }

  Future<void> _saveUser(ChatUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      developer.log('Saved user to preferences: ${user.id}');
    } catch (e) {
      developer.log('Error saving user: $e', error: e);
    }
  }

  @override
  bool get isConnected => _isConnected;

  @override
  ChatUser? get currentUser => _currentUser;

  @override
  Future<ChatUser> createUser(String name, String avatarId) async {
    developer.log('Creating user: $name with avatarId: $avatarId');
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': name,
          'avatar': avatarId,
        }),
      );

      developer.log(
          'Create user response: ${response.statusCode} - ${response.body}');

      if (response.statusCode != 200) {
        throw Exception(
            'Failed to create user: ${response.statusCode} - ${response.body}');
      }

      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      developer.log('Decoded response data: $responseData');

      _currentUser = ChatUser.fromJson(responseData);
      await _saveUser(_currentUser!);
      developer.log('User created successfully: ${_currentUser!.id}');
      return _currentUser!;
    } catch (e, stackTrace) {
      developer.log('Error creating user: $e',
          error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  @override
  Future<void> connect() async {
    if (_currentUser == null) {
      throw Exception('User not created');
    }

    if (_isConnected) {
      return;
    }

    developer.log('Connecting to WebSocket with userId: ${_currentUser!.id}');
    try {
      _channel = WebSocketChannel.connect(
        Uri.parse('$_wsUrl?userId=${_currentUser!.id}'),
      );

      _channel!.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['type'] == 'initial_messages') {
            final messages = (data['messages'] as List)
                .map((m) => ChatMessage.fromJson(m))
                .toList();
            developer.log('Received ${messages.length} initial messages');
            _initialMessagesController.add(messages);
          } else {
            developer.log('Received message: ${data['content']}');
            _messageController.add(ChatMessage.fromJson(data));
          }
        },
        onDone: () {
          developer.log('WebSocket connection closed');
          _handleDisconnection();
        },
        onError: (error) {
          developer.log('WebSocket error: $error', error: error);
          _handleDisconnection();
        },
      );

      _isConnected = true;
      _stopReconnectTimer();
      developer.log('WebSocket connection established');
    } catch (e) {
      developer.log('Error connecting to WebSocket: $e', error: e);
      _handleDisconnection();
      rethrow;
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
      if (_isConnected || _isDisposed) {
        _stopReconnectTimer();
        return;
      }

      try {
        await connect();
      } catch (e) {
        developer.log('Reconnection attempt failed: $e', error: e);
      }
    });
  }

  void _stopReconnectTimer() {
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
  }

  @override
  Future<void> disconnect() async {
    developer.log('Disconnecting from WebSocket');
    _stopReconnectTimer();
    await _channel?.sink.close();
    _isConnected = false;
  }

  void dispose() {
    _isDisposed = true;
    _stopReconnectTimer();
    disconnect();
    _messageController.close();
    _initialMessagesController.close();
  }

  @override
  Future<void> sendMessage(String content, MessageType type) async {
    if (!_isConnected || _currentUser == null) {
      throw Exception('Not connected');
    }

    final message = {
      'type': type.toString().split('.').last,
      'content': content,
      'senderId': _currentUser!.id,
      'timestamp': DateTime.now().toIso8601String(),
    };

    developer.log('Sending message: $content');
    _channel!.sink.add(jsonEncode(message));
  }

  @override
  Stream<ChatMessage> get messageStream => _messageController.stream;

  @override
  Stream<List<ChatMessage>> get initialMessages =>
      _initialMessagesController.stream;
}
