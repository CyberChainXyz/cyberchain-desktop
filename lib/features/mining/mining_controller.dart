import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/program_info.dart';
import '../../core/models/mining_pool.dart';
import '../../core/services/process_service.dart';
import '../../core/services/error_handler.dart';
import '../../core/providers/service_providers.dart';
import '../../core/providers/error_provider.dart';

final miningControllerProvider =
    StateNotifierProvider<MiningController, Map<String, ProgramInfo>>((ref) {
  final controller = MiningController(
    ref.watch(processServiceProvider.notifier),
    ref.read(errorHandlerProvider.notifier),
  );

  return controller;
});

class MiningController extends StateNotifier<Map<String, ProgramInfo>> {
  final ProcessService _processService;
  final ErrorHandler _errorHandler;
  MiningPoolServer? _selectedServer;
  List<String> _selectedDeviceIds = [];
  String _minerAddress = '';

  MiningController(
    this._processService,
    this._errorHandler,
  ) : super({});

  void setSelectedServer(MiningPoolServer? server) {
    _selectedServer = server;
  }

  void setSelectedDevices(List<String> deviceIds) {
    _selectedDeviceIds = deviceIds;
  }

  void setMinerAddress(String address) {
    _minerAddress = address;
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

      final List<String> arguments = [
        '-all',
        '-d=${_selectedDeviceIds.join(",")}',
        '-user=$_minerAddress',
        '-pass=x',
        '-pool=${_selectedServer!.url}',
      ];

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
    for (final program in state.keys) {
      _processService.stopProgram(program);
    }
    super.dispose();
  }
}
