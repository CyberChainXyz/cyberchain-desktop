import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mining_pool.dart';
import '../services/pool_service.dart';
import '../services/preferences_service.dart';
import 'preferences_provider.dart';

final poolServiceProvider = Provider<PoolService>((ref) {
  return PoolService();
});

/// Provides mining pools with immediate local data and background server update
final miningPoolsProvider =
    AsyncNotifierProvider<MiningPoolsNotifier, List<MiningPool>>(() {
  return MiningPoolsNotifier();
});

class MiningPoolsNotifier extends AsyncNotifier<List<MiningPool>> {
  @override
  Future<List<MiningPool>> build() async {
    // Load local pools immediately
    final poolService = ref.watch(poolServiceProvider);
    final localPools = await poolService.loadLocalPools();
    final customServers = await poolService.getCustomPools();

    // Add custom pools if they exist
    if (customServers.isNotEmpty) {
      final customPool = MiningPool(
        name: "Custom Pools",
        link: "",
        servers: customServers,
      );
      localPools.insert(0, customPool);
    }

    // Start fetching server pools in background
    _fetchServerPools();

    return localPools;
  }

  Future<void> _fetchServerPools() async {
    final poolService = ref.read(poolServiceProvider);
    try {
      final serverPools = await poolService.fetchPools();
      final customServers = await poolService.getCustomPools();

      // Add custom pools to server pools if they exist
      if (customServers.isNotEmpty) {
        final customPool = MiningPool(
          name: "Custom Pools",
          link: "",
          servers: customServers,
        );
        serverPools.insert(0, customPool);
      }

      final currentPools = state.valueOrNull ?? [];
      if (_arePoolsDifferent(currentPools, serverPools)) {
        state = AsyncData(serverPools);
      }
    } catch (e) {
      // If fetch fails, keep using local pools
      // No need to update state since we're already showing local pools
    }
  }

  bool _arePoolsDifferent(List<MiningPool> a, List<MiningPool> b) {
    if (a.length != b.length) return true;
    for (var i = 0; i < a.length; i++) {
      if (a[i].name != b[i].name ||
          a[i].link != b[i].link ||
          a[i].servers.length != b[i].servers.length) {
        return true;
      }
      for (var j = 0; j < a[i].servers.length; j++) {
        if (a[i].servers[j].name != b[i].servers[j].name ||
            a[i].servers[j].url != b[i].servers[j].url) {
          return true;
        }
      }
    }
    return false;
  }

  Future<void> refresh() async {
    _fetchServerPools();
  }
}

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

final solutionCountProvider = StateProvider<int>((ref) => 0);
