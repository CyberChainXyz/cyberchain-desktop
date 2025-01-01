import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_info.dart';
import '../../shared/utils/platform_utils.dart';
import 'github_service.dart';
import 'download_service.dart';

class UpdateService extends StateNotifier<Map<String, ProgramInfo>> {
  final GithubService _githubService;
  final DownloadService _downloadService;

  UpdateService(this._githubService, this._downloadService) : super({});

  Future<bool> checkForUpdates(String programName) async {
    final latestVersion = await _githubService.getLatestVersion(programName);
    if (latestVersion == null) return false;

    final currentVersion = state[programName]?.version;
    return currentVersion != null && currentVersion != latestVersion;
  }

  Future<void> updateProgram(String programName) async {
    final latestVersion = await _githubService.getLatestVersion(programName);
    if (latestVersion == null) return;

    final platform = PlatformUtils.getPlatformString();
    final arch = PlatformUtils.getArchString();
    final downloadUrl =
        'https://github.com/CyberChainXyz/$programName/releases/download/$latestVersion/$programName-$platform-$arch';

    final localPath = await PlatformUtils.getProgramPath(programName);
    final program = ProgramInfo(
      name: programName,
      version: latestVersion,
      downloadUrl: downloadUrl,
      localPath: localPath,
    );

    final newPath = await _downloadService.downloadProgram(program);

    state = {
      ...state,
      programName: program.copyWith(localPath: newPath),
    };
  }
}
