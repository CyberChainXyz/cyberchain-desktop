import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'update_service.dart';
import 'program_info_service.dart';
import 'asset_install_service.dart';
import '../providers/app_state_provider.dart';
import '../utils/semver_utils.dart';

class InitService extends StateNotifier<bool> {
  final UpdateService _updateService;
  final ProgramInfoService _programInfoService;
  final DownloadProgressNotifier _downloadProgress;
  final AssetInstallService _assetInstallService;
  final List<String> _requiredPrograms = ['go-cyberchain', 'xMiner'];

  InitService(
    this._updateService,
    this._programInfoService,
    this._downloadProgress,
    this._assetInstallService,
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

  /// Install programs from bundled assets
  /// This is called on first run to install pre-bundled programs
  Future<void> installBundledPrograms() async {
    try {
      await _assetInstallService.installAllPrograms();
      state = true;
    } catch (e) {
      rethrow;
    }
  }

  /// Check and auto-install programs if needed
  /// Returns true if programs exist or were successfully installed
  Future<bool> ensureProgramsExist() async {
    try {
      final isReady = await _areRequiredProgramsReady();
      if (isReady) {
        return true;
      }

      await installBundledPrograms();
      return await _areRequiredProgramsReady();
    } catch (e) {
      return false;
    }
  }

  Future<bool> _areRequiredProgramsReady() async {
    for (final programName in _requiredPrograms) {
      final info = await _programInfoService.getProgramInfo(programName);
      if (info == null) {
        return false;
      }

      final bundledVersion =
          _assetInstallService.getBundledVersion(programName);
      if (bundledVersion == null) {
        continue;
      }

      if (isSemverTagOlder(info.version, bundledVersion)) {
        return false;
      }
    }

    return true;
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
