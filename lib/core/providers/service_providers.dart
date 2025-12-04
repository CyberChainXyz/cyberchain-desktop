import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/process_service.dart';
import '../services/update_service.dart';
import '../services/github_service.dart';
import '../services/init_service.dart';
import '../services/download_service.dart';
import '../services/program_info_service.dart';
import '../services/asset_install_service.dart';
import '../models/program_info.dart';
import 'app_state_provider.dart';

final processServiceProvider =
    StateNotifierProvider<ProcessService, void>((ref) {
  return ProcessService(ref);
});

final githubServiceProvider = Provider<GithubService>((ref) {
  return GithubService(ref.watch(programInfoServiceProvider));
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService(ref.watch(processServiceProvider.notifier));
});

final programInfoServiceProvider = Provider<ProgramInfoService>((ref) {
  return ProgramInfoService();
});

final assetInstallServiceProvider = Provider<AssetInstallService>((ref) {
  return AssetInstallService(ref.watch(programInfoServiceProvider));
});

final updateServiceProvider =
    StateNotifierProvider<UpdateService, Map<String, ProgramInfo>>((ref) {
  return UpdateService(
    ref.watch(githubServiceProvider),
    ref.watch(downloadServiceProvider),
    ref.watch(programInfoServiceProvider),
  );
});

final initServiceProvider = StateNotifierProvider<InitService, bool>((ref) {
  return InitService(
    ref.watch(updateServiceProvider.notifier),
    ref.watch(programInfoServiceProvider),
    ref.watch(downloadProgressProvider.notifier),
    ref.watch(assetInstallServiceProvider),
  );
});
