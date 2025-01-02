import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mining_pool.dart';
import '../services/pool_service.dart';
import '../services/preferences_service.dart';
import 'preferences_provider.dart';

final poolServiceProvider = Provider<PoolService>((ref) {
  return PoolService();
});

final miningPoolsProvider = FutureProvider<List<MiningPool>>((ref) async {
  final poolService = ref.watch(poolServiceProvider);
  // Load local pools first for immediate UI update
  final localPools = await poolService.loadLocalPools();
  // Then fetch latest pools in background
  poolService.fetchPools();
  return localPools;
});

class SelectedDevicesNotifier extends StateNotifier<Set<String>> {
  final PreferencesService _preferencesService;

  SelectedDevicesNotifier(this._preferencesService) : super({}) {
    _loadSavedDevices();
  }

  Future<void> _loadSavedDevices() async {
    state = await _preferencesService.loadSelectedDevices();
  }

  Future<void> toggleDevice(String deviceId) async {
    if (state.contains(deviceId)) {
      state = {...state}..remove(deviceId);
    } else {
      state = {...state, deviceId};
    }
    await _preferencesService.saveSelectedDevices(state);
  }

  Future<void> setDevices(Set<String> devices) async {
    state = devices;
    await _preferencesService.saveSelectedDevices(devices);
  }
}

final selectedDevicesProvider =
    StateNotifierProvider<SelectedDevicesNotifier, Set<String>>((ref) {
  final prefsService = ref.watch(preferencesServiceProvider);
  return SelectedDevicesNotifier(prefsService);
});

class CCXAddressNotifier extends StateNotifier<String> {
  final PreferencesService _preferencesService;

  CCXAddressNotifier(this._preferencesService) : super('') {
    _loadSavedAddress();
  }

  Future<void> _loadSavedAddress() async {
    state = await _preferencesService.loadCCXAddress() ?? '';
  }

  Future<void> setAddress(String address) async {
    state = address;
    await _preferencesService.saveCCXAddress(address);
  }
}

final ccxAddressProvider =
    StateNotifierProvider<CCXAddressNotifier, String>((ref) {
  final prefsService = ref.watch(preferencesServiceProvider);
  return CCXAddressNotifier(prefsService);
});

class GoCyberchainArgsNotifier extends StateNotifier<List<String>> {
  final PreferencesService _preferencesService;

  GoCyberchainArgsNotifier(this._preferencesService) : super([]) {
    _loadSavedArgs();
  }

  Future<void> _loadSavedArgs() async {
    state = await _preferencesService.loadGoCyberchainArgs();
  }

  Future<void> setArgs(List<String> args) async {
    state = args;
    await _preferencesService.saveGoCyberchainArgs(args);
  }
}

final goCyberchainArgsProvider =
    StateNotifierProvider<GoCyberchainArgsNotifier, List<String>>((ref) {
  final prefsService = ref.watch(preferencesServiceProvider);
  return GoCyberchainArgsNotifier(prefsService);
});

class SelectedPoolNotifier extends StateNotifier<MiningPoolServer?> {
  final PreferencesService _preferencesService;

  SelectedPoolNotifier(this._preferencesService) : super(null) {
    _loadSavedPool();
  }

  Future<void> _loadSavedPool() async {
    state = await _preferencesService.loadSelectedPool();
  }

  Future<void> setPool(MiningPoolServer? pool) async {
    state = pool;
    await _preferencesService.saveSelectedPool(pool);
  }
}

final selectedPoolProvider =
    StateNotifierProvider<SelectedPoolNotifier, MiningPoolServer?>((ref) {
  final prefsService = ref.watch(preferencesServiceProvider);
  return SelectedPoolNotifier(prefsService);
});
