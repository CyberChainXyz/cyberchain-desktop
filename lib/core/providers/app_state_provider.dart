import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_info.dart';
import '../models/mining_pool.dart';

class AppState {
  final Map<String, ProgramInfo> programs;
  final List<MiningPool> pools;
  final bool isSoloMining;
  final MiningPool? selectedPool;
  final bool isInitialized;

  const AppState({
    this.programs = const {},
    this.pools = const [],
    this.isSoloMining = true,
    this.selectedPool,
    this.isInitialized = false,
  });

  AppState copyWith({
    Map<String, ProgramInfo>? programs,
    List<MiningPool>? pools,
    bool? isSoloMining,
    MiningPool? selectedPool,
    bool? isInitialized,
  }) {
    return AppState(
      programs: programs ?? this.programs,
      pools: pools ?? this.pools,
      isSoloMining: isSoloMining ?? this.isSoloMining,
      selectedPool: selectedPool ?? this.selectedPool,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void updatePrograms(Map<String, ProgramInfo> programs) {
    state = state.copyWith(programs: programs);
  }

  void updatePools(List<MiningPool> pools) {
    state = state.copyWith(pools: pools);
  }

  void setMiningMode(bool isSoloMining) {
    state = state.copyWith(isSoloMining: isSoloMining);
  }

  void setSelectedPool(MiningPool? pool) {
    state = state.copyWith(selectedPool: pool);
  }

  void setInitialized() {
    state = state.copyWith(isInitialized: true);
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});
