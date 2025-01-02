import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mining_device.dart';
import '../models/mining_pool.dart';

class MiningOutputNotifier extends StateNotifier<String> {
  MiningOutputNotifier() : super('');

  void appendOutput(String newOutput) {
    state = state + newOutput;
  }

  void clear() {
    state = '';
  }
}

final goCyberchainOutputProvider =
    StateNotifierProvider<MiningOutputNotifier, String>((ref) {
  return MiningOutputNotifier();
});

final xMinerOutputProvider =
    StateNotifierProvider<MiningOutputNotifier, String>((ref) {
  return MiningOutputNotifier();
});

final miningDevicesProvider = StateProvider<List<MiningDevice>>((ref) {
  // TODO: Implement device detection
  return [
    const MiningDevice(
      id: 'cpu',
      name: 'CPU',
      type: 'cpu',
    ),
    const MiningDevice(
      id: 'gpu0',
      name: 'GPU 0',
      type: 'gpu',
    ),
  ];
});

final selectedDevicesProvider = StateProvider<Set<String>>((ref) => {});

final selectedPoolProvider = StateProvider<MiningPool?>((ref) => null);

final ccxAddressProvider = StateProvider<String>((ref) => '');
