import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/blockchain_metrics.dart';

class BlockchainService {
  static const _httpUrl = 'http://127.0.0.1:8545';
  static const _wsUrl = 'ws://127.0.0.1:8546';
  static const _timeout = Duration(seconds: 1);
  static const _wsRetryDelay = Duration(seconds: 2);
  static const _throttleDuration = Duration(milliseconds: 300);
  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _throttleTimer;
  bool _shouldReconnect = false;
  bool _isThrottled = false;
  void Function()? _onNewBlock;

  void subscribeToNewBlocks(void Function() onNewBlock) {
    _onNewBlock = onNewBlock;
    _shouldReconnect = true;
    _connectWebSocket();
  }

  void _connectWebSocket() {
    _channel?.sink.close();
    _reconnectTimer?.cancel();

    if (!_shouldReconnect) {
      return;
    }

    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));

      // Subscribe to new block headers
      _channel?.sink.add(jsonEncode({
        'jsonrpc': '2.0',
        'id': 1,
        'method': 'eth_subscribe',
        'params': ['newHeads']
      }));

      _channel?.stream.listen(
        (message) {
          final data = jsonDecode(message);
          if (data['method'] == 'eth_subscription' && !_isThrottled) {
            _isThrottled = true;
            _onNewBlock?.call();

            _throttleTimer?.cancel();
            _throttleTimer = Timer(_throttleDuration, () {
              _isThrottled = false;
            });
          }
        },
        onError: (error) {
          _scheduleReconnect();
        },
        onDone: () {
          _scheduleReconnect();
        },
        cancelOnError: true,
      );
    } catch (e) {
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!_shouldReconnect) {
      return;
    }

    _reconnectTimer?.cancel();
    _throttleTimer?.cancel();
    _isThrottled = false;
    _reconnectTimer = Timer(_wsRetryDelay, () {
      _connectWebSocket();
    });
  }

  void unsubscribe() {
    _shouldReconnect = false;
    _reconnectTimer?.cancel();
    _throttleTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
    _onNewBlock = null;
  }

  Future<BlockchainMetrics> getMetrics() async {
    final client = http.Client();
    try {
      final blockHeightResponse = await client
          .post(
            Uri.parse(_httpUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'jsonrpc': '2.0',
              'method': 'eth_blockNumber',
              'params': [],
              'id': 1
            }),
          )
          .timeout(_timeout);

      final difficultyResponse = await client
          .post(
            Uri.parse(_httpUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'jsonrpc': '2.0',
              'method': 'eth_getBlockByNumber',
              'params': ['latest', false],
              'id': 2
            }),
          )
          .timeout(_timeout);

      final peerCountResponse = await client
          .post(
            Uri.parse(_httpUrl),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'jsonrpc': '2.0',
              'method': 'net_peerCount',
              'params': [],
              'id': 3
            }),
          )
          .timeout(_timeout);

      final blockHeightResult = json.decode(blockHeightResponse.body);
      if (blockHeightResult['error'] != null) {
        throw Exception('RPC error: ${blockHeightResult['error']}');
      }
      final blockHeightHex = blockHeightResult['result'] as String;
      final blockHeight = int.parse(blockHeightHex.substring(2), radix: 16);

      final difficultyResult = json.decode(difficultyResponse.body);
      if (difficultyResult['error'] != null) {
        throw Exception('RPC error: ${difficultyResult['error']}');
      }
      final block = difficultyResult['result'] as Map<String, dynamic>;
      final difficultyHex = block['difficulty'] as String;
      final difficulty = BigInt.parse(difficultyHex.substring(2), radix: 16);

      final peerCountResult = json.decode(peerCountResponse.body);
      if (peerCountResult['error'] != null) {
        throw Exception('RPC error: ${peerCountResult['error']}');
      }
      final peerCountHex = peerCountResult['result'] as String;
      final peerCount = int.parse(peerCountHex.substring(2), radix: 16);

      return BlockchainMetrics(
        blockHeight: blockHeight,
        difficulty: difficulty,
        peerCount: peerCount,
      );
    } catch (e) {
      rethrow;
    } finally {
      client.close();
    }
  }
}
