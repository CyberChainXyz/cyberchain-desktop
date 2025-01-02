import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/providers/mining_providers.dart';
import '../../features/mining/mining_controller.dart';
import '../../core/models/mining_pool.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Navigation Panel
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            minWidth: 120,
            minExtendedWidth: 150,
            labelType: NavigationRailLabelType.all,
            leading: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(0, 24, 0, 16),
                  child: Image(
                    image: AssetImage('assets/images/logo.png'),
                    width: 48,
                    height: 48,
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Divider(
                    thickness: 1,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
            destinations: const [
              NavigationRailDestination(
                padding: EdgeInsets.symmetric(vertical: 12),
                icon: Icon(Icons.lan, size: 28),
                label: Text('CyberChain',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
              NavigationRailDestination(
                padding: EdgeInsets.symmetric(vertical: 12),
                icon: Icon(Icons.memory, size: 28),
                label: Text('xMiner',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          // Vertical Divider
          const VerticalDivider(thickness: 1, width: 1),
          // Content Area
          Expanded(
            child: _selectedIndex == 0
                ? const GoCyberchainView()
                : const XMinerView(),
          ),
        ],
      ),
    );
  }
}

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
    // Watch the program state to automatically update UI when it changes
    final processService = ref.watch(processServiceProvider.notifier);
    final programs = ref.watch(processServiceProvider);
    final isRunning = programs['go-cyberchain']?.isRunning ?? false;
    final isStopping = processService.isProcessStopping('go-cyberchain');
    final output = ref.watch(goCyberchainOutputProvider);

    // Scroll to bottom when output changes
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Control Panel
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
                        ? null // Disable button while stopping or starting or during countdown
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
          // Output Area
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

class XMinerView extends ConsumerStatefulWidget {
  const XMinerView({super.key});

  @override
  ConsumerState<XMinerView> createState() => _XMinerViewState();
}

class _XMinerViewState extends ConsumerState<XMinerView> {
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
    // Watch the program state to automatically update UI when it changes
    final processService = ref.watch(processServiceProvider.notifier);
    final programs = ref.watch(processServiceProvider);
    final isRunning = programs['xMiner']?.isRunning ?? false;
    final isStopping = processService.isProcessStopping('xMiner');
    final devices = ref.watch(miningDevicesProvider);
    final selectedDevices = ref.watch(selectedDevicesProvider);
    final ccxAddress = ref.watch(ccxAddressProvider);
    final selectedPool = ref.watch(selectedPoolProvider);
    final output = ref.watch(xMinerOutputProvider);

    // Scroll to bottom when output changes
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Settings Panel
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // CCX Address Input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'CCX Address',
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      ref.read(ccxAddressProvider.notifier).state = value;
                    },
                    controller: TextEditingController(text: ccxAddress),
                  ),
                  const SizedBox(height: 16),
                  // Mining Pool Selection
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Mining Pool',
                      border: OutlineInputBorder(),
                    ),
                    value: selectedPool?.url,
                    items: const [
                      DropdownMenuItem(
                        value: 'pool1.ccx.org',
                        child: Text('Pool 1'),
                      ),
                      DropdownMenuItem(
                        value: 'pool2.ccx.org',
                        child: Text('Pool 2'),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value != null) {
                        ref.read(selectedPoolProvider.notifier).state =
                            MiningPool(
                          name: value,
                          url: value,
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  // Device Selection
                  const Text(
                    'Select Devices',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: devices.map((device) {
                      final isSelected = selectedDevices.contains(device.id);
                      return FilterChip(
                        label: Text(device.name),
                        selected: isSelected,
                        onSelected: (bool selected) {
                          final newSelection =
                              Set<String>.from(selectedDevices);
                          if (selected) {
                            newSelection.add(device.id);
                          } else {
                            newSelection.remove(device.id);
                          }
                          ref.read(selectedDevicesProvider.notifier).state =
                              newSelection;
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  // Control Buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
                        label: Text(isRunning
                            ? (isStopping
                                ? 'Stopping (${processService.getCountdown('xMiner')})'
                                : 'Stop')
                            : (processService.isProcessStarting('xMiner')
                                ? 'Starting (${processService.getCountdown('xMiner')})'
                                : 'Start')),
                        onPressed: selectedDevices.isEmpty ||
                                ccxAddress.isEmpty ||
                                selectedPool == null ||
                                isStopping ||
                                processService.isProcessStarting('xMiner') ||
                                processService.getCountdown('xMiner') > 0
                            ? null
                            : () {
                                final controller =
                                    ref.read(miningControllerProvider.notifier);
                                if (isRunning) {
                                  controller.stopMining('xMiner');
                                } else {
                                  controller.startPoolMining(selectedPool!);
                                }
                                setState(() {}); // Force refresh the UI
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isRunning
                              ? (isStopping ||
                                      processService.getCountdown('xMiner') > 0
                                  ? Colors.grey
                                  : Colors.red)
                              : (processService.isProcessStarting('xMiner')
                                  ? Colors.grey
                                  : Colors.green),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Output Area
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
