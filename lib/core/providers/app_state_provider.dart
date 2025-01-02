import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_info.dart';
import '../models/mining_pool.dart';

class InitializationState {
  final bool isLoading;
  final bool? programsExist;
  final String? error;

  const InitializationState({
    this.isLoading = true,
    this.programsExist,
    this.error,
  });

  InitializationState copyWith({
    bool? isLoading,
    bool? programsExist,
    String? error,
  }) {
    return InitializationState(
      isLoading: isLoading ?? this.isLoading,
      programsExist: programsExist ?? this.programsExist,
      error: error ?? this.error,
    );
  }
}

class InitializationNotifier extends StateNotifier<InitializationState> {
  InitializationNotifier() : super(const InitializationState());

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setProgramsExist(bool exists) {
    state = state.copyWith(
      programsExist: exists,
      isLoading: false,
    );
  }

  void setError(String error) {
    state = state.copyWith(
      error: error,
      isLoading: false,
    );
  }

  void reset() {
    state = const InitializationState();
  }
}

final initializationProvider =
    StateNotifierProvider<InitializationNotifier, InitializationState>((ref) {
  return InitializationNotifier();
});

class AppState {
  final Map<String, ProgramInfo> programs;
  final List<MiningPool> pools;
  final bool isSoloMining;
  final MiningPool? selectedPool;
  final bool isInitialized;
  final Map<String, double> downloadProgress;
  final bool isProgramsReady;

  const AppState({
    this.programs = const {},
    this.pools = const [],
    this.isSoloMining = true,
    this.selectedPool,
    this.isInitialized = false,
    this.downloadProgress = const {},
    this.isProgramsReady = false,
  });

  AppState copyWith({
    Map<String, ProgramInfo>? programs,
    List<MiningPool>? pools,
    bool? isSoloMining,
    MiningPool? selectedPool,
    bool? isInitialized,
    Map<String, double>? downloadProgress,
    bool? isProgramsReady,
  }) {
    return AppState(
      programs: programs ?? this.programs,
      pools: pools ?? this.pools,
      isSoloMining: isSoloMining ?? this.isSoloMining,
      selectedPool: selectedPool ?? this.selectedPool,
      isInitialized: isInitialized ?? this.isInitialized,
      downloadProgress: downloadProgress ?? this.downloadProgress,
      isProgramsReady: isProgramsReady ?? this.isProgramsReady,
    );
  }

  @override
  String toString() {
    return 'AppState(isInitialized: $isInitialized, isProgramsReady: $isProgramsReady, downloadProgress: $downloadProgress)';
  }
}

class AppStateNotifier extends StateNotifier<AppState> {
  AppStateNotifier() : super(const AppState());

  void updatePrograms(Map<String, ProgramInfo> programs) {
    print('Updating programs: $programs');
    state = state.copyWith(programs: programs);
    print('New state: $state');
  }

  void updatePools(List<MiningPool> pools) {
    print('Updating pools: $pools');
    state = state.copyWith(pools: pools);
    print('New state: $state');
  }

  void setMiningMode(bool isSoloMining) {
    print('Setting mining mode: $isSoloMining');
    state = state.copyWith(isSoloMining: isSoloMining);
    print('New state: $state');
  }

  void setSelectedPool(MiningPool? pool) {
    print('Setting selected pool: $pool');
    state = state.copyWith(selectedPool: pool);
    print('New state: $state');
  }

  void setInitialized() {
    print('Setting initialized state');
    state = state.copyWith(isInitialized: true);
    print('New state: $state');
  }

  void updateDownloadProgress(String program, double progress) {
    print('Updating download progress for $program: $progress');
    final newProgress = Map<String, double>.from(state.downloadProgress);
    newProgress[program] = progress;
    state = state.copyWith(downloadProgress: newProgress);
    print('New state: $state');
  }

  void setProgramsReady(bool ready) {
    print('Setting programs ready state: $ready');
    state = state.copyWith(isProgramsReady: ready);
    print('New state: $state');
  }
}

final appStateProvider =
    StateNotifierProvider<AppStateNotifier, AppState>((ref) {
  return AppStateNotifier();
});

class DownloadProgress {
  final Map<String, double> progress;
  final Set<String> downloading;

  const DownloadProgress({
    this.progress = const {},
    this.downloading = const {},
  });

  DownloadProgress copyWith({
    Map<String, double>? progress,
    Set<String>? downloading,
  }) {
    return DownloadProgress(
      progress: progress ?? this.progress,
      downloading: downloading ?? this.downloading,
    );
  }
}

class DownloadProgressNotifier extends StateNotifier<DownloadProgress> {
  DownloadProgressNotifier() : super(const DownloadProgress());

  void startDownload(String program) {
    state = state.copyWith(
      progress: {...state.progress, program: 0},
      downloading: {...state.downloading, program},
    );
  }

  void updateProgress(String program, double progress) {
    state = state.copyWith(
      progress: {...state.progress, program: progress},
    );
  }

  void finishDownload(String program) {
    final newProgress = Map<String, double>.from(state.progress);
    newProgress.remove(program);
    final newDownloading = Set<String>.from(state.downloading);
    newDownloading.remove(program);

    state = state.copyWith(
      progress: newProgress,
      downloading: newDownloading,
    );
  }
}

final downloadProgressProvider =
    StateNotifierProvider<DownloadProgressNotifier, DownloadProgress>((ref) {
  return DownloadProgressNotifier();
});
