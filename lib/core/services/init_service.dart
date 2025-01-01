import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../providers/service_providers.dart';
import 'github_service.dart';
import 'update_service.dart';

class InitService {
  final GithubService _githubService;
  final UpdateService _updateService;

  InitService(this._githubService, this._updateService);

  Future<void> initialize() async {
    await _initializePrograms();
    await _initializePools();
  }

  Future<void> _initializePrograms() async {
    final programs = [AppConstants.goCyberchainRepo, AppConstants.xMinerRepo];

    for (final program in programs) {
      final version = await _githubService.getLatestVersion(program);
      if (version == null) continue;

      await _updateService.updateProgram(program);
    }
  }

  Future<void> _initializePools() async {
    await _githubService.getMiningPools();
  }
}

final initServiceProvider = Provider<InitService>((ref) {
  return InitService(
    ref.watch(githubServiceProvider),
    ref.watch(updateServiceProvider.notifier),
  );
});
