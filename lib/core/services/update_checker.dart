import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/app_constants.dart';
import '../providers/service_providers.dart';
import 'github_service.dart';

class UpdateChecker extends StateNotifier<Map<String, bool>> {
  final GithubService _githubService;
  Timer? _timer;

  UpdateChecker(this._githubService) : super({});

  void startChecking() {
    _timer?.cancel();
    _timer = Timer.periodic(AppConstants.updateCheckInterval, (_) {
      checkUpdates();
    });
  }

  Future<void> checkUpdates() async {
    final programs = ['go-cyberchain', 'xMiner'];
    for (final program in programs) {
      final hasUpdate = await _githubService.checkForUpdates(program);
      if (hasUpdate) {
        state = {...state, program: true};
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final updateCheckerProvider =
    StateNotifierProvider<UpdateChecker, Map<String, bool>>((ref) {
  return UpdateChecker(ref.watch(githubServiceProvider));
});
