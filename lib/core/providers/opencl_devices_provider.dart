import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/opencl_device.dart';
import '../../shared/utils/platform_utils.dart';

final openclDevicesProvider = FutureProvider<List<OpenCLDevice>>((ref) async {
  try {
    // Get the program path
    final programPath = await PlatformUtils.getProgramPath('xMiner');
    final programDir = Directory(programPath).parent.path;

    // Run the command and wait for it to complete
    final result = await Process.run(
      programPath,
      ['-info', '-all'],
      workingDirectory: programDir,
      runInShell: true,
    );

    if (result.exitCode != 0) {
      return [];
    }

    return OpenCLDevice.parseDevices(result.stdout as String);
  } catch (e) {
    return [];
  }
});
