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
    print('Extracting executable from $archivePath, looking for $programName');
    final bytes = await File(archivePath).readAsBytes();
    final Archive archive = archivePath.endsWith('.zip')
        ? ZipDecoder().decodeBytes(bytes)
        : TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));

    // Print all files in archive for debugging
    print('Files in archive:');
    archive.files.forEach((file) => print('- ${file.name}'));

    // Get the correct executable name
    final executableName = _getExecutableName(programName);
    print('Looking for executable with name: $executableName');

    // Find the executable file, which might be in a subdirectory
    final executableEntry = archive.files.firstWhere(
      (file) {
        final fileName = path.basename(file.name);
        final isExecutable = fileName == executableName;
        print('Checking file: ${file.name} (isExecutable: $isExecutable)');
        return file.isFile && isExecutable;
      },
      orElse: () =>
          throw Exception('Executable not found in archive: $executableName'),
    );

    print('Found executable: ${executableEntry.name}');

    if (executableEntry.isFile) {
      // Get the correct program path using PlatformUtils
      final outputPath = await PlatformUtils.getProgramPath(
          originalProgramName ?? programName);
      print('Extracting to: $outputPath');

      final File outputFile = File(outputPath);
      final outputDir = Directory(path.dirname(outputPath));
      if (!outputDir.existsSync()) {
        outputDir.createSync(recursive: true);
      }
      await outputFile.writeAsBytes(executableEntry.content as List<int>);

      // Make the file executable on Unix-like systems
      if (!Platform.isWindows) {
        print('Making file executable');
        await Process.run('chmod', ['+x', outputPath]);
      }

      return outputPath;
    }

    throw Exception('Failed to extract executable');
  }
}
