import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/service_providers.dart';
import '../../core/providers/mining_providers.dart';
import '../../core/providers/opencl_devices_provider.dart';
import '../../features/mining/mining_controller.dart';
import '../../core/models/mining_pool.dart';
import '../../core/utils/address_validator.dart';
import '../../core/providers/output_providers.dart';

class XMinerView extends ConsumerStatefulWidget {
  const XMinerView({super.key});

  @override
  ConsumerState<XMinerView> createState() => _XMinerViewState();
}

class _XMinerViewState extends ConsumerState<XMinerView> {
  final ScrollController _scrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  String? _addressError;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    _controller.dispose();
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
    final isRunning = programs['xMiner']?.isRunning ?? false;
    final isStopping = processService.isProcessStopping('xMiner');
    final selectedDevices = ref.watch(selectedDevicesProvider);
    final ccxAddress = ref.watch(ccxAddressProvider);
    final selectedPool = ref.watch(selectedPoolProvider);
    final output = ref.watch(xMinerOutputProvider);

    // Update controller text when ccxAddress changes
    if (_controller.text != ccxAddress) {
      _controller.text = ccxAddress;
    }

    final isOperating = isStopping ||
        processService.isProcessStarting('xMiner') ||
        processService.getCountdown('xMiner') > 0;

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: 'CCX Address',
                              border: const OutlineInputBorder(),
                              errorText: _addressError,
                              helperText:
                                  'EVM address (0x...) or EVM address with suffix (0x....name)',
                              helperMaxLines: 2,
                            ),
                            onChanged: (value) {
                              // Clear error when user is typing
                              if (_addressError != null) {
                                setState(() {
                                  _addressError = null;
                                });
                              }
                            },
                            focusNode: _focusNode
                              ..addListener(() {
                                // Only show error when focus is lost
                                if (!_focusNode.hasFocus) {
                                  final value = _controller.text;
                                  final error =
                                      AddressValidator.validateCCXAddress(
                                          value);
                                  setState(() {
                                    _addressError = error;
                                  });
                                  // Save address regardless of validation
                                  ref
                                      .read(ccxAddressProvider.notifier)
                                      .setAddress(value);
                                }
                              }),
                            controller: _controller,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 2,
                          child: ref.watch(miningPoolsProvider).when(
                                data: (pools) {
                                  final selectedServer =
                                      ref.watch(selectedPoolProvider);
                                  return DropdownButtonFormField<
                                      MiningPoolServer>(
                                    isExpanded: true,
                                    decoration: const InputDecoration(
                                      labelText: 'Mining Pool',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 16,
                                      ),
                                    ),
                                    value: selectedServer,
                                    items: pools
                                        .expand<
                                            DropdownMenuItem<
                                                MiningPoolServer>>((pool) => [
                                              DropdownMenuItem<
                                                  MiningPoolServer>(
                                                enabled: false,
                                                value: null,
                                                child: Text(
                                                  pool.name,
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.grey,
                                                  ),
                                                ),
                                              ),
                                              ...pool.servers.map(
                                                (server) => DropdownMenuItem<
                                                    MiningPoolServer>(
                                                  value: server,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 16.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Flexible(
                                                          child: Text(
                                                            server.name,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 8),
                                                        Flexible(
                                                          child: Text(
                                                            server.url,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            style: TextStyle(
                                                              fontSize: 12,
                                                              color: Theme.of(
                                                                      context)
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.color,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ])
                                        .toList(),
                                    onChanged: (MiningPoolServer? value) {
                                      if (value != null) {
                                        ref
                                            .read(selectedPoolProvider.notifier)
                                            .setPool(value);
                                      }
                                    },
                                  );
                                },
                                loading: () => const SizedBox(
                                  height: 56,
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                ),
                                error: (error, stack) => SizedBox(
                                  height: 56,
                                  child: Center(
                                    child: Text('Error: $error'),
                                  ),
                                ),
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Select Devices',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Consumer(
                      builder: (context, ref, child) {
                        final openclDevicesAsync =
                            ref.watch(openclDevicesProvider);

                        return openclDevicesAsync.when(
                          data: (devices) {
                            if (devices.isEmpty) {
                              return const Text(
                                'No OpenCL devices found',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontStyle: FontStyle.italic,
                                ),
                              );
                            }

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                childAspectRatio: 8,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                              ),
                              itemCount: devices.length,
                              itemBuilder: (context, index) {
                                final device = devices[index];
                                final isSelected = selectedDevices
                                    .contains(device.id.toString());
                                return Card(
                                  child: InkWell(
                                    onTap: () {
                                      setState(() {
                                        if (isSelected) {
                                          selectedDevices
                                              .remove(device.id.toString());
                                        } else {
                                          selectedDevices
                                              .add(device.id.toString());
                                        }
                                        ref
                                            .read(selectedDevicesProvider
                                                .notifier)
                                            .setDevices(selectedDevices);
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8),
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: isSelected
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .primary
                                              : Colors.transparent,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Row(
                                        children: [
                                          Checkbox(
                                            value: isSelected,
                                            onChanged: (bool? value) {
                                              setState(() {
                                                if (value ?? false) {
                                                  selectedDevices.add(
                                                      device.id.toString());
                                                } else {
                                                  selectedDevices.remove(
                                                      device.id.toString());
                                                }
                                                ref
                                                    .read(
                                                        selectedDevicesProvider
                                                            .notifier)
                                                    .setDevices(
                                                        selectedDevices);
                                              });
                                            },
                                          ),
                                          Text(
                                            '[${device.id}]',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              device.name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          loading: () => const CircularProgressIndicator(),
                          error: (error, stack) => Text(
                            'Error loading devices: $error',
                            style: const TextStyle(
                              color: Colors.red,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
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
                          onPressed: isOperating ||
                                  isRunning ||
                                  !AddressValidator.isValidCCXAddress(
                                      ccxAddress) ||
                                  selectedPool == null ||
                                  selectedDevices.isEmpty
                              ? (isOperating || !isRunning
                                  ? null
                                  : () {
                                      final controller = ref.read(
                                          miningControllerProvider.notifier);
                                      controller.stopMining();
                                    })
                              : () {
                                  final controller = ref
                                      .read(miningControllerProvider.notifier);
                                  controller.setSelectedServer(selectedPool);
                                  controller.startMining();
                                  setState(() {});
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isRunning
                                ? (isOperating ? Colors.grey : Colors.red)
                                : (isOperating ||
                                        !AddressValidator.isValidCCXAddress(
                                            ccxAddress) ||
                                        selectedPool == null ||
                                        selectedDevices.isEmpty
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
