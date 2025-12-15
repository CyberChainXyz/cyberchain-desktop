import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/program_info.dart';
import 'program_info_service.dart';
import '../../shared/utils/platform_utils.dart';
import '../utils/semver_utils.dart';

/// Service to handle installing bundled programs from assets
class AssetInstallService {
  final ProgramInfoService _programInfoService;

  AssetInstallService(this._programInfoService);

  static const Map<String, ({String assetPath, String version})>
      bundledPrograms = {
    'go-cyberchain': (
      assetPath: 'assets/programs/go-cyberchain',
      version: 'v1.3.0',
    ),
    'xMiner': (
      assetPath: 'assets/programs/xMiner',
      version: 'v0.2.0',
    ),
  };

  String? getBundledVersion(String programName) =>
      bundledPrograms[programName]?.version;

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
    // Use PlatformUtils to ensure consistency with other services
    final executableName = PlatformUtils.getProgramFileName(programName);
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
    // Use the actual executable name (e.g., 'ccx' for go-cyberchain)
    // to match what UpdateService saves
    final urlProgramName = programName == 'go-cyberchain' ? 'ccx' : programName;
    final programInfo = ProgramInfo(
      name: urlProgramName,
      version: version,
      downloadUrl: 'bundled', // Mark as bundled program
      localPath: targetPath,
    );

    await _programInfoService.updateProgramInfo(programName, programInfo);
  }

  /// Install all required programs if they don't exist
  Future<void> installAllPrograms() async {
    for (final entry in bundledPrograms.entries) {
      final programName = entry.key;
      final assetPath = entry.value.assetPath;
      final bundledVersion = entry.value.version;

      final info = await _programInfoService.getProgramInfo(programName);
      final needsInstall =
          info == null || isSemverTagOlder(info.version, bundledVersion);

      if (!needsInstall) {
        continue;
      }

      await installProgram(
        programName: programName,
        assetPath: assetPath,
        version: bundledVersion,
      );
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
