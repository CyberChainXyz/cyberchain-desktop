import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../core/providers/service_providers.dart';
import '../../core/providers/output_providers.dart';
import '../../core/providers/mining_providers.dart';
import '../../core/providers/blockchain_providers.dart';

class GoCyberchainView extends ConsumerStatefulWidget {
  const GoCyberchainView({super.key});

  @override
  ConsumerState<GoCyberchainView> createState() => _GoCyberchainViewState();
}

class _GoCyberchainViewState extends ConsumerState<GoCyberchainView> {
  final ScrollController _scrollController = ScrollController();
  final _numberFormat = NumberFormat('#,###');

  String _formatBigInt(BigInt? value) {
    if (value == null) return '--';
    final str = value.toString();
    final buffer = StringBuffer();
    final length = str.length;
    for (var i = 0; i < length; i++) {
      if (i > 0 && (length - i) % 3 == 0) {
        buffer.write(',');
      }
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

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

  Widget _buildMetricsCard() {
    final metrics = ref.watch(blockchainMetricsNotifierProvider);
    final processService = ref.watch(processServiceProvider.notifier);
    final isRunning = processService.isProcessRunning('go-cyberchain');

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildMetricItem(
              'Block Height',
              isRunning ? metrics.value?.blockHeight.toString() ?? '--' : '--',
              Icons.layers,
            ),
            _buildMetricItem(
              'Difficulty',
              isRunning ? _formatBigInt(metrics.value?.difficulty) : '--',
              Icons.speed,
            ),
            _buildMetricItem(
              'Peers',
              isRunning ? metrics.value?.peerCount.toString() ?? '--' : '--',
              Icons.people,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final processService = ref.watch(processServiceProvider.notifier);
    final isRunning = processService.isProcessRunning('go-cyberchain');
    final isStopping = processService.isProcessStopping('go-cyberchain');
    final isStarting = processService.isProcessStarting('go-cyberchain');
    final output = ref.watch(goCyberchainOutputProvider);
    final savedArgs = ref.watch(goCyberchainArgsProvider);

    final isOperating = isStopping || isStarting;

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
                        ? (isStopping ? 'Stopping...' : 'Stop')
                        : (isStarting ? 'Starting...' : 'Start')),
                    onPressed: isOperating
                        ? null
                        : () {
                            if (isRunning) {
                              processService.stopProgram('go-cyberchain');
                            } else {
                              processService.startProgram(
                                  'go-cyberchain', savedArgs);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isRunning
                          ? (isStopping ? Colors.grey : Colors.red)
                          : (isStarting ? Colors.grey : Colors.green),
                      foregroundColor: Colors.white,
                    ),
                  ),
                  if (savedArgs.isNotEmpty) ...[
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Arguments: ${savedArgs.join(" ")}',
                        style: Theme.of(context).textTheme.bodySmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricsCard(),
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
