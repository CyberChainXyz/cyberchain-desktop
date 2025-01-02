import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'update_service.dart';
import 'program_info_service.dart';
import '../providers/app_state_provider.dart';

class InitService extends StateNotifier<bool> {
  final UpdateService _updateService;
  final ProgramInfoService _programInfoService;
  final DownloadProgressNotifier _downloadProgress;
  final List<String> _requiredPrograms = ['go-cyberchain', 'xMiner'];

  InitService(
    this._updateService,
    this._programInfoService,
    this._downloadProgress,
  ) : super(false);

  Future<bool> checkProgramsExist() async {
    try {
      for (final programName in _requiredPrograms) {
        final exists = await _programInfoService.programExists(programName);
        if (!exists) {
          return false;
        }
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> downloadPrograms() async {
    try {
      for (final programName in _requiredPrograms) {
        if (!await _programInfoService.programExists(programName)) {
          _downloadProgress.startDownload(programName);

          try {
            await _updateService.updateProgram(
              programName,
              onProgress: (progress) {
                _downloadProgress.updateProgress(programName, progress);
              },
            );
          } catch (e) {
            rethrow;
          } finally {
            _downloadProgress.finishDownload(programName);
          }
        }
      }
      state = true;
    } catch (e) {
      rethrow;
    }
  }
}
