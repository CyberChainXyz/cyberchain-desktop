import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../core/providers/mining_providers.dart';
import '../../features/mining/mining_controller.dart';

class GoCyberchainView extends ConsumerStatefulWidget {
  const GoCyberchainView({super.key});

  @override
  ConsumerState<GoCyberchainView> createState() => _GoCyberchainViewState();
}

class _GoCyberchainViewState extends ConsumerState<GoCyberchainView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final processService = ref.watch(processServiceProvider.notifier);
    final programs = ref.watch(processServiceProvider);
    final isRunning = programs['go-cyberchain']?.isRunning ?? false;
    final isStopping = processService.isProcessStopping('go-cyberchain');
    final output = ref.watch(goCyberchainOutputProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  ElevatedButton.icon(
                    icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
                    label: Text(isRunning
                        ? (isStopping
                            ? 'Stopping (${processService.getCountdown('go-cyberchain')})'
                            : 'Stop')
                        : (processService.isProcessStarting('go-cyberchain')
                            ? 'Starting (${processService.getCountdown('go-cyberchain')})'
                            : 'Start')),
                    onPressed: isStopping ||
                            processService.isProcessStarting('go-cyberchain') ||
                            processService.getCountdown('go-cyberchain') > 0
                        ? null
                        : () {
                            final controller =
                                ref.read(miningControllerProvider.notifier);
                            if (isRunning) {
                              controller.stopMining('go-cyberchain');
                            } else {
                              controller.startSoloMining();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning
                          ? (isStopping ||
                                  processService.getCountdown('go-cyberchain') >
                                      0
                              ? Colors.grey
                              : Colors.red)
                          : (processService.isProcessStarting('go-cyberchain')
                              ? Colors.grey
                              : Colors.green),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: RawScrollbar(
                          controller: _scrollController,
                          thumbVisibility: true,
                          trackVisibility: true,
                          thickness: 12,
                          thumbColor: Colors.grey[600],
                          radius: const Radius.circular(4),
                          child: SingleChildScrollView(
                            controller: _scrollController,
                            child: SelectableText(
                              output.isNotEmpty
                                  ? output
                                  : (isRunning
                                      ? 'Starting program...'
                                      : 'Program is not running'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
