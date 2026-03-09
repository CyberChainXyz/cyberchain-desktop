import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../../core/utils/custom_http_client.dart';
import '../../../core/utils/user_agent_utils.dart';
import '../models/chat_message.dart';
import '../models/chat_user.dart';
import 'chat_service.dart';

/// A completely rewritten WebSocket chat service implementation.
/// Re-architected based on functional requirements (state management, 
/// reconnection mechanisms, user credential persistence, message dispatching).
/// Responsibilities are split into modules, improving code cohesion, 
/// readability, and fault tolerance.
class WebSocketChatService implements ChatService {
  // ===========================================================================
  // Configuration & Environment
  // ===========================================================================
  static const String _prodApiBase = 'https://chat.cyberchain.xyz';
  static const String _devApiBase = 'http://127.0.0.1:8080';
  static const String _prodWsBase = 'wss://chat.cyberchain.xyz/ws';
  static const String _devWsBase = 'ws://127.0.0.1:8080/ws';

  static const String _prefsKeyProd = 'chat_user';
  static const String _prefsKeyDev = 'chat_user_dev';

  // Do not force test environment by default unless specifically needed
  bool get _isDev => kDebugMode && false;

  String get _apiBase => _isDev ? _devApiBase : _prodApiBase;
  String get _wsBase => _isDev ? _devWsBase : _prodWsBase;
  String get _prefsKey => _isDev ? _prefsKeyDev : _prefsKeyProd;

  // ===========================================================================
  // Core State
  // ===========================================================================
  ChatUser? _currentUser;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  String? _currentChannelId;
  Timer? _reconnectTimer;
  Timer? _pingTimer;
  DateTime? _lastSeen;

  final Completer<void> _initCompleter = Completer<void>();
  final StreamController<ChatMessage> _messageController =
      StreamController<ChatMessage>.broadcast();
  final StreamController<List<ChatMessage>> _initialMessagesController =
      StreamController<List<ChatMessage>>.broadcast();

  bool _isConnected = false;
  bool _isConnecting = false;
  bool _intentionalDisconnect = false;

  WebSocketChatService() {
    _initializeUser();
  }

  // ===========================================================================
  // Initialization & User Management
  // ===========================================================================

  /// Restore user data from local cache
  Future<void> _initializeUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_prefsKey);
      if (userJson != null) {
        _currentUser = ChatUser.fromJson(jsonDecode(userJson));
      }
    } catch (e) {
      // Ignore cache restore errors
    } finally {
      _initCompleter.complete();
    }
  }

  Future<void> get initialized => _initCompleter.future;

  @override
  ChatUser? get currentUser => _currentUser;

  @override
  bool get isConnected => _isConnected;

  @override
  Future<ChatUser> createUser(String name, String avatarId) async {
    final client = getClient();
    try {
      final response = await client.post(
        Uri.parse('$_apiBase/api/users'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': name,
          'avatar': avatarId,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception(
            'API Error [${response.statusCode}]: ${response.body}');
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final user = ChatUser.fromJson(data);

      // Persist user data
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefsKey, jsonEncode(user.toJson()));

      _currentUser = user;
      return user;
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }

  // ===========================================================================
  // Connection Management
  // ===========================================================================

  @override
  Future<void> connect({required String channelId}) async {
    if (_currentUser == null) {
      throw Exception('Cannot connect without an initialized user.');
    }
    if (_isConnected || _isConnecting) {
      return;
    }

    _isConnecting = true;
    _intentionalDisconnect = false;
    _currentChannelId = channelId;

    try {
      // Ensure any existing resources are cleaned up before a new attempt
      _cleanupConnection();
      
      final wsUri = Uri.parse('$_wsBase/$channelId');

      _channel = IOWebSocketChannel.connect(
        wsUri,
        protocols: [
          _currentUser!.id,
          _currentUser!.secretKey,
          UserAgentUtils.getUserAgent(),
        ],
        headers: {
          'User-Agent': UserAgentUtils.getUserAgent(),
        },
        pingInterval: null,
        connectTimeout: const Duration(seconds: 15),
      );

      // Wait for the underlying connection to be established
      await _channel!.ready;

      _isConnected = true;
      _lastSeen = DateTime.now();
      _cancelReconnectTimer();
      _startPingTimer();

      // Start listening to the channel data stream
      _subscription = _channel!.stream.listen(
        _onMessageReceived,
        onError: _onError,
        onDone: _onDone,
        cancelOnError: false,
      );
    } catch (e) {
      // Critical: Cleanup on failure to prevent resource leaks
      _cleanupConnection();
      _scheduleReconnect();
      rethrow;
    } finally {
      _isConnecting = false;
    }
  }

  @override
  Future<void> disconnect() async {
    _intentionalDisconnect = true;
    _currentChannelId = null;
    
    _cancelReconnectTimer();
    _cleanupConnection();
  }

  Future<void> _cleanupConnection() async {
    _isConnected = false;
    _lastSeen = null;
    _stopPingTimer();
    
    final sub = _subscription;
    _subscription = null;
    
    final channel = _channel;
    _channel = null;

    // Do not await these indefinitely as they can hang in poor network conditions
    if (sub != null) {
      sub.cancel().catchError((e) => {});
    }
    if (channel != null) {
      channel.sink.close().catchError((e) => {});
    }
  }

  void _startPingTimer() {
    _stopPingTimer();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!_isConnected) return;

      // Check for heartbeat timeout
      if (_lastSeen != null) {
        final now = DateTime.now();
        final silenceDuration = now.difference(_lastSeen!);
        if (silenceDuration > const Duration(seconds: 45)) {
          _handleUnexpectedDisconnection();
          return;
        }
      }

      sendMessage(jsonEncode({'type': 'ping'}));
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  // ===========================================================================
  // Message Handling & Dispatch
  // ===========================================================================

  void _onMessageReceived(dynamic payload) {
    _lastSeen = DateTime.now();
    try {
      final decoded = jsonDecode(payload);
      if (decoded is! Map<String, dynamic>) return;

      if (decoded['type'] == 'ping') {
        sendMessage(jsonEncode({'type': 'pong'}));
        return;
      }
      
      if (decoded['type'] == 'pong') {
        return;
      }

      if (decoded['type'] == 'initial_messages') {
        final messagesList = decoded['messages'] as List?;
        if (messagesList != null) {
          final messages = messagesList
              .map((m) => ChatMessage.fromJson(m as Map<String, dynamic>))
              .toList();
          _initialMessagesController.add(messages);
        }
      } else {
        _messageController.add(ChatMessage.fromJson(decoded));
      }
    } catch (e) {
      // Ignore parsing errors
    }
  }

  @override
  Future<void> sendMessage(String content) async {
    if (!_isConnected || _channel == null) {
      throw Exception('Cannot send message: WebSocket is disconnected.');
    }
    _channel!.sink.add(content);
  }

  @override
  Stream<ChatMessage> get messageStream => _messageController.stream;

  @override
  Stream<List<ChatMessage>> get initialMessages =>
      _initialMessagesController.stream;

  // ===========================================================================
  // Reconnection Logic
  // ===========================================================================

  void _onError(Object error, StackTrace stackTrace) {
    _handleUnexpectedDisconnection();
  }

  void _onDone() {
    _handleUnexpectedDisconnection();
  }

  Future<void> _handleUnexpectedDisconnection() async {
    if (_intentionalDisconnect) return;

    _cleanupConnection();
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect || _currentChannelId == null) return;
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      return;
    }

    _cancelReconnectTimer();
    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      if (_currentChannelId != null) {
        connect(channelId: _currentChannelId!).catchError((e) {
          // Errors here are caught by the catch block in connect and will trigger 
          // _scheduleReconnect again. This catch prevents unhandled exception crashes.
        });
      }
    });
  }

  void _cancelReconnectTimer() {
    if (_reconnectTimer != null) {
      _reconnectTimer?.cancel();
      _reconnectTimer = null;
    }
  }

  // ===========================================================================
  // Resource Cleanup
  // ===========================================================================

  void dispose() {
    disconnect();
    _messageController.close();
    _initialMessagesController.close();
  }
}
