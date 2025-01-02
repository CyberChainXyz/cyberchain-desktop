import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_info.dart';
import '../../shared/utils/platform_utils.dart';
import '../../shared/utils/string_utils.dart';
import 'github_service.dart';
import 'download_service.dart';
import 'program_info_service.dart';

class UpdateService extends StateNotifier<Map<String, ProgramInfo>> {
  final GithubService _githubService;
  final DownloadService _downloadService;
  final ProgramInfoService _programInfoService;

  UpdateService(
      this._githubService, this._downloadService, this._programInfoService)
      : super({}) {
    _loadSavedState();
  }

  Future<void> _loadSavedState() async {
    final savedState = await _programInfoService.loadProgramInfo();
    state = savedState;
  }

  Future<bool> checkForUpdates(String programName) async {
    final latestVersion = await _githubService.getLatestVersion(programName);
    if (latestVersion == null) {
      return false;
    }

    final currentVersion = state[programName]?.version;
    return currentVersion != null && currentVersion != latestVersion;
  }

  Future<void> updateProgram(
    String programName, {
    void Function(double)? onProgress,
  }) async {
    final latestVersion = await _githubService.getLatestVersion(programName);
    if (latestVersion == null) {
      return;
    }

    final platform = PlatformUtils.getPlatformString();
    final arch = 'X64';
    final extension = platform == 'windows' ? 'zip' : 'tar.gz';
    final urlProgramName = programName == 'go-cyberchain' ? 'ccx' : programName;

    final downloadUrl =
        'https://github.com/cyberchainxyz/$programName/releases/download/$latestVersion/$urlProgramName-${platform.capitalize()}-$arch-$latestVersion.$extension';

    final localPath = await PlatformUtils.getProgramPath(programName);
    final program = ProgramInfo(
      name: urlProgramName,
      version: latestVersion,
      downloadUrl: downloadUrl,
      localPath: localPath,
      isRunning: false,
      output: '',
    );

    final newPath = await _downloadService.downloadProgram(
      program,
      onProgress: onProgress,
      originalProgramName: programName,
    );

    final updatedProgram = program.copyWith(localPath: newPath);
    state = {
      ...state,
      programName: updatedProgram,
    };

    // Save the updated program info
    await _programInfoService.updateProgramInfo(programName, updatedProgram);
  }
}
