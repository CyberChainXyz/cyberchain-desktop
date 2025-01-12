import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../providers/service_providers.dart';
import 'github_service.dart';

class ProgramUpdateNotifier extends StateNotifier<bool> {
  final GithubService _githubService;
  Timer? _timer;

  ProgramUpdateNotifier(this._githubService) : super(false) {
    startChecking();
  }

  void startChecking() {
    _timer?.cancel();
    _timer = Timer.periodic(AppConstants.updateCheckInterval, (_) {
      checkUpdates();
    });
    // Check immediately when started
    checkUpdates();
  }

  Future<void> checkUpdates() async {
    final programs = ['go-cyberchain', 'xMiner'];
    for (final program in programs) {
      final hasUpdate = await _githubService.checkForUpdates(program);
      if (hasUpdate) {
        state = true;
        return;
      }
    }
    state = false;
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// Provides a boolean indicating if any program has an update available
final programsUpdateProvider =
    StateNotifierProvider<ProgramUpdateNotifier, bool>((ref) {
  return ProgramUpdateNotifier(ref.watch(githubServiceProvider));
});
