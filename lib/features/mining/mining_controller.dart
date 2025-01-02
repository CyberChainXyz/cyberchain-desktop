import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/program_info.dart';
import '../../core/models/mining_pool.dart';
import '../../core/services/process_service.dart';
import '../../core/services/update_service.dart';
import '../../core/services/error_handler.dart';
import '../../core/providers/service_providers.dart';
import '../../core/providers/error_provider.dart';
import '../settings/settings_controller.dart';

final miningControllerProvider =
    StateNotifierProvider<MiningController, Map<String, ProgramInfo>>((ref) {
  final controller = MiningController(
    ref.watch(processServiceProvider.notifier),
    ref.watch(updateServiceProvider.notifier),
    ref.watch(settingsProvider),
    ref.read(errorHandlerProvider.notifier),
  );

  ref.listen(settingsProvider, (previous, next) {
    if (next.autoStartMining && previous?.autoStartMining == false) {
      controller.startMining();
    }
  });

  return controller;
});

class MiningController extends StateNotifier<Map<String, ProgramInfo>> {
  final ProcessService _processService;
  final UpdateService _updateService;
  final Settings _settings;
  final ErrorHandler _errorHandler;
  bool _isSoloMining = true;
  MiningPool? _selectedPool;

  MiningController(
    this._processService,
    this._updateService,
    this._settings,
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
        }) {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_settings.autoStartMining) {
      await startMining();
    }
  }

  void setMiningMode(bool isSoloMining) {
    _isSoloMining = isSoloMining;
  }

  void setSelectedPool(MiningPool? pool) {
    _selectedPool = pool;
  }

  Future<void> startMining() async {
    try {
      if (_isSoloMining) {
        await startSoloMining();
      } else if (_selectedPool != null) {
        await startPoolMining(_selectedPool!);
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

  Future<void> startPoolMining(MiningPool pool) async {
    await _processService.startProgram(
      'xMiner',
      [
        '--pool',
        pool.url,
        '--threads',
        _settings.minerThreads.toString(),
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
