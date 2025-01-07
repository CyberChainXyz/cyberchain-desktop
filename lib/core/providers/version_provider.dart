import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/version_service.dart';

final versionServiceProvider = Provider((ref) => VersionService());

final currentVersionProvider = FutureProvider<String>((ref) async {
  final versionService = ref.watch(versionServiceProvider);
  return versionService.getCurrentVersion();
});

final hasUpdateProvider =
    StateNotifierProvider<_HasUpdateNotifier, bool>((ref) {
  final versionService = ref.watch(versionServiceProvider);
  return _HasUpdateNotifier(versionService);
});

class _HasUpdateNotifier extends StateNotifier<bool> {
  final VersionService _versionService;

  _HasUpdateNotifier(this._versionService) : super(false) {
    _versionService.startPeriodicCheck((hasUpdate) {
      state = hasUpdate;
    });
  }

  @override
  void dispose() {
    _versionService.stopPeriodicCheck();
    super.dispose();
  }
}
