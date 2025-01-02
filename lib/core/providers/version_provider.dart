import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/version_service.dart';

final versionServiceProvider = Provider((ref) => VersionService());

final currentVersionProvider = FutureProvider<String>((ref) async {
  final versionService = ref.watch(versionServiceProvider);
  return versionService.getCurrentVersion();
});

final hasUpdateProvider = FutureProvider<bool>((ref) async {
  final versionService = ref.watch(versionServiceProvider);
  return versionService.hasUpdate();
});
