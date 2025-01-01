import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_info.dart';
import '../services/github_service.dart';
import '../services/download_service.dart';
import '../services/process_service.dart';
import '../services/update_service.dart';

final githubServiceProvider = Provider<GithubService>((ref) {
  return GithubService();
});

final downloadServiceProvider = Provider<DownloadService>((ref) {
  return DownloadService();
});

final processServiceProvider = Provider<ProcessService>((ref) {
  return ProcessService();
});

final updateServiceProvider =
    StateNotifierProvider<UpdateService, Map<String, ProgramInfo>>((ref) {
  return UpdateService(
    ref.watch(githubServiceProvider),
    ref.watch(downloadServiceProvider),
  );
});
