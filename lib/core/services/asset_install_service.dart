import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/program_info.dart';
import 'program_info_service.dart';

/// Service to handle installing bundled programs from assets
class AssetInstallService {
  final ProgramInfoService _programInfoService;

  AssetInstallService(this._programInfoService);

  /// Get the actual executable name for a program
  /// go-cyberchain uses 'ccx' as executable name
  String _getExecutableName(String programName) {
    if (programName == 'go-cyberchain') {
      return Platform.isWindows ? 'ccx.exe' : 'ccx';
    }
    return Platform.isWindows ? '$programName.exe' : programName;
  }

  /// Install a program from bundled assets to the application directory
  ///
  /// [programName] - Name of the program (e.g., 'go-cyberchain', 'xMiner')
  /// [assetPath] - Path to the program in assets (e.g., 'assets/programs/go-cyberchain')
  /// [version] - Version of the bundled program
  Future<void> installProgram({
    required String programName,
    required String assetPath,
    required String version,
  }) async {
    // Get the target directory
    final appDir = await getApplicationSupportDirectory();
    final programDir = path.join(appDir.path, programName);
    final targetDir = Directory(programDir);

    // Create directory if it doesn't exist
    if (!targetDir.existsSync()) {
      targetDir.createSync(recursive: true);
    }

    // Get actual executable name (ccx for go-cyberchain)
    final executableName = _getExecutableName(programName);
    final targetPath = path.join(programDir, executableName);

    // Copy the program file from assets
    final assetFile = path.join(assetPath, executableName);
    final byteData = await rootBundle.load(assetFile);
    final buffer = byteData.buffer;

    await File(targetPath).writeAsBytes(
      buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes),
    );

    // Make the file executable on Unix-like systems
    if (Platform.isLinux || Platform.isMacOS) {
      final result = await Process.run('chmod', ['+x', targetPath]);
      if (result.exitCode != 0) {
        throw Exception('Failed to make program executable: ${result.stderr}');
      }
    }

    // Save program info
    final programInfo = ProgramInfo(
      name: programName,
      version: version,
      downloadUrl: 'bundled', // Mark as bundled program
      localPath: targetPath,
    );

    await _programInfoService.updateProgramInfo(programName, programInfo);
  }

  /// Install all required programs if they don't exist
  Future<void> installAllPrograms() async {
    final programs = [
      {
        'name': 'go-cyberchain',
        'assetPath': 'assets/programs/go-cyberchain',
        'version': 'v1.3.0', // Update this to match your bundled version
      },
      {
        'name': 'xMiner',
        'assetPath': 'assets/programs/xMiner',
        'version': 'v0.2.0', // Update this to match your bundled version
      },
    ];

    for (final program in programs) {
      final exists = await _programInfoService.programExists(program['name']!);
      if (!exists) {
        await installProgram(
          programName: program['name']!,
          assetPath: program['assetPath']!,
          version: program['version']!,
        );
      }
    }
  }

  /// Check if all required programs are installed
  Future<bool> allProgramsInstalled() async {
    final goCyberchainExists =
        await _programInfoService.programExists('go-cyberchain');
    final xMinerExists = await _programInfoService.programExists('xMiner');
    return goCyberchainExists && xMinerExists;
  }
}
