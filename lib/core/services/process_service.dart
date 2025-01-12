import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/output_providers.dart';
import '../providers/mining_providers.dart';
import '../../shared/utils/platform_utils.dart';

class ProcessService extends StateNotifier<Map<String, Process>> {
  final Map<String, Process> _processes = {};
  final Map<String, bool> _startingProcesses = {};
  final Map<String, bool> _stoppingProcesses = {};
  final Map<String, String> _outputs = {};
  final Ref _ref;

  ProcessService(this._ref) : super({});

  bool isProcessStopping(String name) => _stoppingProcesses[name] ?? false;
  bool isProcessStarting(String name) => _startingProcesses[name] ?? false;
  bool isProcessRunning(String name) => _processes.containsKey(name);

  void _notifyStateChange() {
    state = Map.from(_processes);
  }

  void _appendOutput(String name, String output) {
    _outputs[name] = (_outputs[name] ?? '') + output;

    // Use the appropriate output provider based on the program name
    if (name == 'go-cyberchain') {
      _ref.read(goCyberchainOutputProvider.notifier).appendOutput(output);
    } else if (name == 'xMiner') {
      _ref.read(xMinerOutputProvider.notifier).appendOutput(output);

      // Parse solution count for xMiner
      if (output.contains('Solutions accepted:')) {
        _ref.read(solutionCountProvider.notifier).state += 1;
      }
    }
  }

  Future<void> startProgram(String name, List<String> arguments) async {
    // Prevent starting if already running or in transition
    if (_processes[name] != null ||
        _startingProcesses[name] == true ||
        _stoppingProcesses[name] == true) {
      return;
    }

    _startingProcesses[name] = true;
    _notifyStateChange();

    // Clear output when starting
    _outputs[name] = '';
    if (name == 'go-cyberchain') {
      _ref.read(goCyberchainOutputProvider.notifier).clear();
      if (!arguments.contains('-http')) {
        arguments = [...arguments, '-http'];
      }
      if (!arguments.contains('-ws')) {
        arguments = [...arguments, '-ws'];
      }
    } else if (name == 'xMiner') {
      _ref.read(xMinerOutputProvider.notifier).clear();
    }

    try {
      // Get the program path and directory
      final programPath = await PlatformUtils.getProgramPath(name);
      final programDir = Directory(programPath).parent.path;

      // Run the process and capture output
      final process = await Process.start(
        programPath,
        arguments,
        workingDirectory: programDir,
        mode: ProcessStartMode.normal,
        runInShell: true,
        includeParentEnvironment: true,
      );

      _processes[name] = process;
      _startingProcesses[name] = false;
      _notifyStateChange();

      // Handle stdout
      process.stdout
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          _appendOutput(name, '$line\n');
        },
        onError: (error) {
          _appendOutput(name, '\nError reading output: $error\n');
        },
      );

      // Handle stderr
      process.stderr
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen(
        (line) {
          _appendOutput(name, '$line\n');
        },
        onError: (error) {
          _appendOutput(name, '\nError reading error output: $error\n');
        },
      );

      // Handle process exit
      process.exitCode.then((exitCode) {
        _handleProcessExit(name, exitCode);
      });
    } catch (e) {
      _startingProcesses[name] = false;
      _notifyStateChange();
      _appendOutput(name, '\nError starting program: $e\n');
      rethrow;
    }
  }

  Future<void> stopProgram(String name) async {
    final process = _processes[name];
    // Prevent stopping if not running or already stopping
    if (process == null || _stoppingProcesses[name] == true) {
      return;
    }

    try {
      // Set stopping state first
      _stoppingProcesses[name] = true;
      _notifyStateChange();

      // Send stop signal immediately
      if (Platform.isWindows) {
        await Process.run('taskkill', ['/F', '/T', '/PID', '${process.pid}']);
        // Wait for process to exit on Windows
        await process.exitCode;
      } else {
        // First try graceful termination
        await Process.run('pkill', ['-TERM', '-P', '${process.pid}']);
        process.kill(ProcessSignal.sigterm);

        // Wait for the process to exit gracefully
        bool exited = false;
        while (!exited) {
          try {
            final result = await Process.run('pgrep', ['-P', '${process.pid}']);
            final mainResult =
                await Process.run('ps', ['-p', '${process.pid}']);

            if (result.exitCode != 0 && mainResult.exitCode != 0) {
              exited = true;
            } else {
              await Future.delayed(const Duration(seconds: 1));
            }
          } catch (e) {
            // Process might be already gone
            exited = true;
          }
        }

        // Double check process is really gone
        try {
          await process.exitCode;
        } catch (e) {
          // Process is already dead
        }
      }

      // Update state only after process is confirmed to be stopped
      _processes.remove(name);
      _stoppingProcesses[name] = false;
      _notifyStateChange();
      _appendOutput(name, '\nProgram stopped\n');
    } catch (e) {
      // Even on error, wait for process to be really gone
      try {
        await process.exitCode;
      } catch (e) {
        // Process is already dead
      }

      _processes.remove(name);
      _stoppingProcesses[name] = false;
      _notifyStateChange();
      _appendOutput(name, '\nError stopping program: $e\n');
      rethrow;
    }
  }

  // Handle process exit
  void _handleProcessExit(String name, int exitCode) {
    // Always update state when process exits
    _processes.remove(name);
    _stoppingProcesses[name] = false;
    _startingProcesses[name] = false;
    _notifyStateChange();

    if (exitCode != 0) {
      _appendOutput(name, '\nProgram exited with error code: $exitCode\n');
    } else {
      _appendOutput(name, '\nProgram exited normally\n');
    }
  }

  @override
  void dispose() {
    for (final process in _processes.values) {
      try {
        process.kill();
      } catch (e) {
        // Ignore error
      }
    }
    _processes.clear();
    _stoppingProcesses.clear();
    _startingProcesses.clear();
    _outputs.clear();
    _notifyStateChange();
    super.dispose();
  }
}
