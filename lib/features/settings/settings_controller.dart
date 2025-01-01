import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_constants.dart';

class Settings {
  final int minerThreads;
  final bool autoCheckUpdates;
  final bool autoStartMining;

  const Settings({
    this.minerThreads = AppConstants.defaultMinerThreads,
    this.autoCheckUpdates = true,
    this.autoStartMining = false,
  });

  Settings copyWith({
    int? minerThreads,
    bool? autoCheckUpdates,
    bool? autoStartMining,
  }) {
    return Settings(
      minerThreads: minerThreads ?? this.minerThreads,
      autoCheckUpdates: autoCheckUpdates ?? this.autoCheckUpdates,
      autoStartMining: autoStartMining ?? this.autoStartMining,
    );
  }
}

class SettingsController extends StateNotifier<Settings> {
  static const _minerThreadsKey = 'minerThreads';
  static const _autoCheckUpdatesKey = 'autoCheckUpdates';
  static const _autoStartMiningKey = 'autoStartMining';

  SettingsController() : super(const Settings()) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    state = Settings(
      minerThreads:
          prefs.getInt(_minerThreadsKey) ?? AppConstants.defaultMinerThreads,
      autoCheckUpdates: prefs.getBool(_autoCheckUpdatesKey) ?? true,
      autoStartMining: prefs.getBool(_autoStartMiningKey) ?? false,
    );
  }

  Future<void> setMinerThreads(int threads) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_minerThreadsKey, threads);
    state = state.copyWith(minerThreads: threads);
  }

  Future<void> setAutoCheckUpdates(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoCheckUpdatesKey, value);
    state = state.copyWith(autoCheckUpdates: value);
  }

  Future<void> setAutoStartMining(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoStartMiningKey, value);
    state = state.copyWith(autoStartMining: value);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsController, Settings>((ref) {
  return SettingsController();
});
