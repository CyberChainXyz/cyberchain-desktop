import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/program_info.dart';
import '../../core/models/mining_pool.dart';
import '../../core/services/process_service.dart';
import '../../core/services/update_service.dart';
import '../../core/services/error_handler.dart';
import '../../core/providers/service_providers.dart';
import '../../core/providers/error_provider.dart';

final miningControllerProvider =
    StateNotifierProvider<MiningController, Map<String, ProgramInfo>>((ref) {
  final controller = MiningController(
    ref.watch(processServiceProvider.notifier),
    ref.watch(updateServiceProvider.notifier),
    ref.read(errorHandlerProvider.notifier),
  );

  return controller;
});

class MiningController extends StateNotifier<Map<String, ProgramInfo>> {
  final ProcessService _processService;
  final UpdateService _updateService;
  final ErrorHandler _errorHandler;
  bool _isSoloMining = true;
  MiningPoolServer? _selectedServer;
  static const int defaultMinerThreads = 2;

  MiningController(
    this._processService,
    this._updateService,
    this._errorHandler,
  ) : super({
          'go-cyberchain': const ProgramInfo(
            name: 'go-cyberchain',
            version: 'unknown',
            downloadUrl: '',
            localPath: '',
          ),
          'xMiner': const ProgramInfo(
            name: 'xMiner',
            version: 'unknown',
            downloadUrl: '',
            localPath: '',
          ),
        });

  void setMiningMode(bool isSoloMining) {
    _isSoloMining = isSoloMining;
  }

  void setSelectedServer(MiningPoolServer? server) {
    _selectedServer = server;
  }

  Future<void> startMining() async {
    try {
      if (_isSoloMining) {
        await startSoloMining();
      } else if (_selectedServer != null) {
        await startPoolMining(_selectedServer!);
      } else {
        _errorHandler.handleError(
          'mining',
          'Please select a mining pool before starting pool mining',
        );
      }
    } catch (e) {
      _errorHandler.handleError('mining', 'Failed to start mining: $e');
    }
  }

  Future<void> startSoloMining() async {
    await _processService.startProgram(
      'go-cyberchain',
      [],
    );
  }

  Future<void> startPoolMining(MiningPoolServer server) async {
    await _processService.startProgram(
      'xMiner',
      [
        '--pool',
        server.url,
        '--threads',
        defaultMinerThreads.toString(),
      ],
    );
  }

  Future<void> stopMining(String program) async {
    try {
      await _processService.stopProgram(program);
    } catch (e) {
      _errorHandler.handleError('mining', 'Failed to stop mining: $e');
    }
  }

  Future<void> checkForUpdates(String program) async {
    try {
      if (await _updateService.checkForUpdates(program)) {
        await updateProgram(program);
      }
    } catch (e) {
      _errorHandler.handleError('updates', 'Failed to check for updates: $e');
    }
  }

  Future<void> updateProgram(String program) async {
    try {
      return _updateService.updateProgram(program);
    } catch (e) {
      _errorHandler.handleError('updates', 'Failed to update program: $e');
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
