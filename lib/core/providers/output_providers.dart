import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProcessOutputNotifier extends StateNotifier<String> {
  ProcessOutputNotifier() : super('');

  void appendOutput(String newOutput) {
    state = state + newOutput;
  }

  void clear() {
    state = '';
  }
}

final goCyberchainOutputProvider =
    StateNotifierProvider<ProcessOutputNotifier, String>((ref) {
  return ProcessOutputNotifier();
});

final xMinerOutputProvider =
    StateNotifierProvider<ProcessOutputNotifier, String>((ref) {
  return ProcessOutputNotifier();
});
