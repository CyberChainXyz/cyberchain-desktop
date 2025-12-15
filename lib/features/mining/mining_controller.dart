import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../core/models/mining_pool.dart';
import '../../core/services/process_service.dart';
import '../../core/services/error_handler.dart';
import '../../core/providers/service_providers.dart';
import '../../core/providers/error_provider.dart';
import '../../core/providers/mining_providers.dart';
import '../../core/utils/proxy_validator.dart';
import '../../shared/widgets/loading_dialog.dart';

final miningControllerProvider =
    StateNotifierProvider<MiningController, void>((ref) {
  final controller = MiningController(
    ref.watch(processServiceProvider.notifier),
    ref.read(errorHandlerProvider.notifier),
    ref,
  );

  return controller;
});

class MiningController extends StateNotifier<void> {
  final ProcessService _processService;
  final ErrorHandler _errorHandler;
  final Ref _ref;
  MiningPoolServer? _selectedServer;
  List<String> _selectedDeviceIds = [];
  String _minerAddress = '';
  BuildContext? _context;

  MiningController(
    this._processService,
    this._errorHandler,
    this._ref,
  ) : super(null);

  void setContext(BuildContext context) {
    _context = context;
  }

  void setSelectedServer(MiningPoolServer? server) {
    _selectedServer = server;
  }

  void setSelectedDevices(List<String> deviceIds) {
    _selectedDeviceIds = deviceIds;
  }

  void setMinerAddress(String address) {
    _minerAddress = address;
  }

  String _getBaseAddress(String address) {
    // Remove any suffix after ./@
    final match =
        RegExp(r'^(0x[a-fA-F0-9]{40})([./@].+)?$').firstMatch(address);
    return match?.group(1) ?? address;
  }

  Future<void> _ensureGoCyberchainRunning() async {
    if (_selectedServer == null || _minerAddress.isEmpty) return;

    // Only handle Local pool
    if (_selectedServer!.name != 'Local' ||
        _selectedServer!.url != 'ws://127.0.0.1:8546') return;

    final baseAddress = _getBaseAddress(_minerAddress);
    final requiredArgs = ['-ws', '-mine', '-miner.etherbase=$baseAddress'];

    // Check if go-cyberchain is running and get current args
    final isRunning = _processService.isProcessRunning('go-cyberchain');
    final currentArgs = _ref.read(goCyberchainArgsProvider);
    final needsRestart =
        isRunning && !const ListEquality().equals(currentArgs, requiredArgs);
    final needsStart = !isRunning;

    if (needsStart || needsRestart) {
      // Show loading dialog without awaiting
      if (_context != null) {
        LoadingDialog.show(
          _context!,
          message: needsRestart
              ? 'Restarting go-cyberchain node with new settings...\nPlease wait.'
              : 'Starting go-cyberchain node...\nPlease wait.',
        );
      }

      try {
        if (needsRestart) {
          await _processService.stopProgram('go-cyberchain');
        }
        await _ref
            .read(goCyberchainArgsProvider.notifier)
            .setArgs(requiredArgs);
        await _processService.startProgram('go-cyberchain', requiredArgs);

        // Wait for go-cyberchain to be ready
        await Future.delayed(const Duration(seconds: 5));
      } finally {
        // Hide loading dialog
        if (_context != null && _context!.mounted) {
          LoadingDialog.hide(_context!);
        }
      }
    }
  }

  Future<void> startMining() async {
    try {
      if (_minerAddress.isEmpty) {
        _errorHandler.handleError(
          'mining',
          'Please set a valid miner address before starting',
        );
        return;
      }

      if (_selectedDeviceIds.isEmpty) {
        _errorHandler.handleError(
          'mining',
          'Please select at least one device before starting',
        );
        return;
      }

      if (_selectedServer == null) {
        _errorHandler.handleError(
          'mining',
          'Please select a mining pool before starting mining',
        );
        return;
      }

      final proxy = _ref.read(xMinerProxyProvider).trim();
      final proxyError = ProxyValidator.validate(proxy);
      if (proxyError != null) {
        _errorHandler.handleError('mining', proxyError);
        return;
      }

      // Ensure go-cyberchain is running if needed
      await _ensureGoCyberchainRunning();

      final List<String> arguments = [
        '-all',
        '-d=${_selectedDeviceIds.join(",")}',
        '-user=$_minerAddress',
        '-pass=x',
        '-pool=${_selectedServer!.url}',
      ];

      if (proxy.isNotEmpty) {
        arguments.add('-proxy=$proxy');
      }

      // Start xMiner with the configured arguments
      await _processService.startProgram('xMiner', arguments);
    } catch (e) {
      _errorHandler.handleError('mining', 'Failed to start mining: $e');
    }
  }

  Future<void> stopMining() async {
    try {
      await _processService.stopProgram('xMiner');
    } catch (e) {
      _errorHandler.handleError('mining', 'Failed to stop mining: $e');
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
