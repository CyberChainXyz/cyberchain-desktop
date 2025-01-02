import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/program_info.dart';
import '../../core/models/mining_pool.dart';
import '../../shared/widgets/console_output.dart';
import '../../shared/widgets/program_status.dart';
import '../../core/providers/mining_providers.dart';
import 'mining_controller.dart';
import 'mining_pools_provider.dart';
import '../../core/services/update_checker.dart';
import '../../core/providers/error_provider.dart';
import '../settings/settings_controller.dart';
import '../settings/settings_page.dart';

class MiningPage extends ConsumerStatefulWidget {
  const MiningPage({super.key});

  @override
  ConsumerState<MiningPage> createState() => _MiningPageState();
}

class _MiningPageState extends ConsumerState<MiningPage> {
  MiningPool? selectedPool;
  bool isSoloMining = true;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider);
    if (settings.autoStartMining) {
      ref.read(miningControllerProvider.notifier).startMining();
    }
  }

  @override
  Widget build(BuildContext context) {
    final programs = ref.watch(miningControllerProvider);
    final controller = ref.read(miningControllerProvider.notifier);
    final poolsAsync = ref.watch(miningPoolsProvider);
    final updates = ref.watch(updateCheckerProvider);
    final errors = ref.watch(errorHandlerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('CCX Mining'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (errors.isNotEmpty)
            Container(
              color: Colors.red[100],
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      errors.values.first.message,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      ref
                          .read(errorHandlerProvider.notifier)
                          .clearError(errors.keys.first);
                    },
                  ),
                ],
              ),
            ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: ProgramStatus(
                          program: programs['go-cyberchain'] ??
                              const ProgramInfo(
                                name: 'go-cyberchain',
                                version: 'unknown',
                                downloadUrl: '',
                                localPath: '',
                              ),
                          onStart: () => controller.startSoloMining(),
                          onStop: () => controller.stopMining('go-cyberchain'),
                          onUpdate: () =>
                              controller.updateProgram('go-cyberchain'),
                          hasUpdate: updates['go-cyberchain'] ?? false,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ProgramStatus(
                          program: programs['xMiner'] ??
                              const ProgramInfo(
                                name: 'xMiner',
                                version: 'unknown',
                                downloadUrl: '',
                                localPath: '',
                              ),
                          onStart: () {
                            if (selectedPool != null) {
                              controller.startPoolMining(selectedPool!);
                            }
                          },
                          onStop: () => controller.stopMining('xMiner'),
                          onUpdate: () => controller.updateProgram('xMiner'),
                          hasUpdate: updates['xMiner'] ?? false,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SegmentedButton<bool>(
                        segments: const [
                          ButtonSegment(
                            value: true,
                            label: Text('Solo Mining'),
                          ),
                          ButtonSegment(
                            value: false,
                            label: Text('Pool Mining'),
                          ),
                        ],
                        selected: {isSoloMining},
                        onSelectionChanged: (value) {
                          final isSoloMining = value.first;
                          setState(() {
                            this.isSoloMining = isSoloMining;
                          });
                          controller.setMiningMode(isSoloMining);
                        },
                      ),
                      if (!isSoloMining) ...[
                        const SizedBox(width: 16),
                        Expanded(
                          child: poolsAsync.when(
                            data: (pools) =>
                                DropdownButtonFormField<MiningPool>(
                              value: selectedPool,
                              decoration: const InputDecoration(
                                labelText: 'Select Mining Pool',
                                border: OutlineInputBorder(),
                              ),
                              items: pools
                                  .map((pool) => DropdownMenuItem(
                                        value: pool,
                                        child: Text(pool.name),
                                      ))
                                  .toList(),
                              onChanged: (pool) {
                                setState(() {
                                  selectedPool = pool;
                                });
                                controller.setSelectedPool(pool);
                              },
                            ),
                            loading: () => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            error: (err, stack) => Text('Error: $err'),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ConsoleOutput(
                      output: isSoloMining
                          ? ref.watch(goCyberchainOutputProvider)
                          : ref.watch(xMinerOutputProvider),
                      isRunning: isSoloMining
                          ? programs['go-cyberchain']?.isRunning ?? false
                          : programs['xMiner']?.isRunning ?? false,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
