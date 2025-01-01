import 'dart:io';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_info.dart';

class ProcessService extends StateNotifier<Map<String, ProgramInfo>> {
  final Map<String, Process> _processes = {};

  ProcessService() : super({});

  Future<void> startProgram(String name, List<String> arguments) async {
    if (state[name]?.isRunning ?? false) return;

    final process = await Process.start(
      state[name]!.localPath,
      arguments,
      mode: ProcessStartMode.detachedWithStdio,
    );

    _processes[name] = process;

    process.stdout.transform(utf8.decoder).listen((output) {
      state = {
        ...state,
        name: state[name]!.copyWith(
          output: state[name]!.output + output,
          isRunning: true,
        ),
      };
    });

    process.stderr.transform(utf8.decoder).listen((output) {
      state = {
        ...state,
        name: state[name]!.copyWith(
          output: state[name]!.output + output,
          isRunning: true,
        ),
      };
    });

    process.exitCode.then((_) {
      _processes.remove(name);
      state = {
        ...state,
        name: state[name]!.copyWith(isRunning: false),
      };
    });
  }

  Future<void> stopProgram(String name) async {
    final process = _processes[name];
    if (process == null) return;

    if (Platform.isWindows) {
      await Process.run('taskkill', ['/F', '/PID', '${process.pid}']);
    } else {
      process.kill();
    }

    _processes.remove(name);
    state = {
      ...state,
      name: state[name]!.copyWith(isRunning: false),
    };
  }

  @override
  void dispose() {
    for (final process in _processes.values) {
      process.kill();
    }
    _processes.clear();
    super.dispose();
  }
}
