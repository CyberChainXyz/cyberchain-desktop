import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as path;
import 'platform_utils.dart';

class ArchiveUtils {
  static String _getExecutableName(String programName) {
    String baseName = programName;
    switch (programName) {
      case 'go-cyberchain':
        baseName = 'ccx';
        break;
      case 'xMiner':
        baseName = 'xMiner';
        break;
    }
    return Platform.isWindows ? '$baseName.exe' : baseName;
  }

  static Future<String> extractExecutable(
    String archivePath,
    String programName, {
    String? originalProgramName,
  }) async {
    final bytes = await File(archivePath).readAsBytes();
    final Archive archive = archivePath.endsWith('.zip')
        ? ZipDecoder().decodeBytes(bytes)
        : TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));

    // Get the correct executable name
    final executableName = _getExecutableName(programName);

    // Find the executable file, which might be in a subdirectory
    final executableEntry = archive.files.firstWhere(
      (file) {
        final fileName = path.basename(file.name);
        final isExecutable = fileName == executableName;
        return file.isFile && isExecutable;
      },
      orElse: () =>
          throw Exception('Executable not found in archive: $executableName'),
    );

    if (executableEntry.isFile) {
      // Get the correct program path using PlatformUtils
      final outputPath = await PlatformUtils.getProgramPath(
          originalProgramName ?? programName);

      final File outputFile = File(outputPath);
      final outputDir = Directory(path.dirname(outputPath));
      if (!outputDir.existsSync()) {
        outputDir.createSync(recursive: true);
      }
      await outputFile.writeAsBytes(executableEntry.content as List<int>);

      // Make the file executable on Unix-like systems
      if (!Platform.isWindows) {
        await Process.run('chmod', ['+x', outputPath]);
      }

      return outputPath;
    }

    throw Exception('Failed to extract executable');
  }
}
