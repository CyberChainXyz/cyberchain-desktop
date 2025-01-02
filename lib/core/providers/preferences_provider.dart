import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/preferences_service.dart';
import '../models/mining_pool.dart';

final preferencesServiceProvider = Provider<PreferencesService>((ref) {
  return PreferencesService();
});

final savedCCXAddressProvider = FutureProvider<String?>((ref) async {
  final prefsService = ref.watch(preferencesServiceProvider);
  return prefsService.loadCCXAddress();
});

final savedPoolServerProvider = FutureProvider<MiningPoolServer?>((ref) async {
  final prefsService = ref.watch(preferencesServiceProvider);
  return prefsService.loadSelectedPool();
});

final savedDevicesProvider = FutureProvider<Set<String>>((ref) async {
  final prefsService = ref.watch(preferencesServiceProvider);
  return prefsService.loadSelectedDevices();
});
