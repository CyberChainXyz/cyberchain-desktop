import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/blockchain_metrics.dart';
import '../services/blockchain_service.dart';
import 'service_providers.dart';

part 'blockchain_providers.g.dart';

@Riverpod(keepAlive: true)
class BlockchainMetricsNotifier extends AsyncNotifier<BlockchainMetrics?> {
  final _blockchainService = BlockchainService();
  Timer? _retryTimer;

  @override
  FutureOr<BlockchainMetrics?> build() {
    ref.onDispose(() {
      _blockchainService.unsubscribe();
      _retryTimer?.cancel();
    });

    // Listen to process service state changes
    ref.listen(processServiceProvider, (previous, next) {
      _checkProcessState();
    });

    // Initial check
    return _checkProcessState();
  }

  Future<BlockchainMetrics?> _checkProcessState() async {
    _retryTimer?.cancel();
    final processService = ref.read(processServiceProvider.notifier);
    final isRunning = processService.isProcessRunning('go-cyberchain');

    if (isRunning) {
      // Subscribe to new blocks
      _blockchainService.subscribeToNewBlocks(() {
        _updateMetrics();
      });

      // Get initial metrics with retry
      return _getMetricsWithRetry();
    } else {
      _blockchainService.unsubscribe();
      return null;
    }
  }

  Future<BlockchainMetrics?> _getMetricsWithRetry() async {
    try {
      final metrics = await _blockchainService.getMetrics();
      return metrics;
    } catch (e) {
      // Schedule a retry after 2 seconds
      _retryTimer = Timer(const Duration(seconds: 2), () {
        _updateMetrics();
      });
      return null;
    }
  }

  Future<void> _updateMetrics() async {
    try {
      final metrics = await _blockchainService.getMetrics();
      state = AsyncData(metrics);
    } catch (e) {
      // Schedule a retry after 2 seconds
      _retryTimer = Timer(const Duration(seconds: 2), () {
        _updateMetrics();
      });
    }
  }
}
