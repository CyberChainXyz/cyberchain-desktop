#!/usr/bin/env dart
// Script to download the latest program releases from GitHub
// and place them in assets/programs/ for bundling

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:archive/archive.dart';

const String baseUrl = 'https://api.github.com/repos/cyberchainxyz';
const String fallbackBaseUrl = 'https://file.cyberchain.xyz/fallback/';

/// Get the current platform string
String getPlatformString() {
  if (Platform.isWindows) return 'windows';
  if (Platform.isMacOS) return 'darwin';
  if (Platform.isLinux) return 'linux';
  throw UnsupportedError('Unsupported platform');
}

/// Get the architecture string
String getArchString() {
  // Check environment variable first (useful for CI)
  final envArch = Platform.environment['BUILD_ARCH'];
  if (envArch != null) return envArch.toLowerCase();

  // Fallback to runtime detection
  if (Platform.version.contains('x64')) return 'x64';
  if (Platform.version.contains('arm64') ||
      Platform.version.contains('aarch64')) {
    return 'arm64';
  }
  return 'x64'; // Default to x64
}

/// Get the latest version for a program from GitHub
Future<String?> getLatestVersion(String program) async {
  final url = '$baseUrl/$program/releases/latest';

  print('Fetching latest version for $program...');

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'CCX-Desktop-Build-Script',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final version = data['tag_name'] as String;
      print('  Latest version: $version');
      return version;
    }
  } catch (e) {
    print('  Failed to get latest release: $e');
  }

  // Fallback: try to get the first release
  try {
    final url = '$baseUrl/$program/releases';
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/vnd.github.v3+json',
        'User-Agent': 'CCX-Desktop-Build-Script',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> releases = jsonDecode(response.body);
      if (releases.isNotEmpty) {
        final version = releases[0]['tag_name'] as String;
        print('  Latest version (from releases list): $version');
        return version;
      }
    }
  } catch (e) {
    print('  Failed to get releases: $e');
  }

  return null;
}

/// Download a file from a URL
Future<File> downloadFile(String url, String savePath) async {
  print('  Downloading from: $url');

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
      print('  Downloaded: ${file.lengthSync()} bytes');
      return file;
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
    }
  } catch (e) {
    // Try fallback URL
    final fileName = path.basename(url);
    final fallbackUrl = '$fallbackBaseUrl$fileName';
    print('  Primary download failed, trying fallback: $fallbackUrl');

    final response = await http.get(Uri.parse(fallbackUrl));

    if (response.statusCode == 200) {
      final file = File(savePath);
      await file.writeAsBytes(response.bodyBytes);
      print('  Downloaded from fallback: ${file.lengthSync()} bytes');
      return file;
    } else {
      throw Exception('Fallback also failed: HTTP ${response.statusCode}');
    }
  }
}

/// Extract executable from archive
Future<String> extractExecutable(
  String archivePath,
  String programName,
  String outputDir,
) async {
  print('  Extracting executable...');

  final bytes = await File(archivePath).readAsBytes();
  Archive? archive;

  // Determine executable name
  String executableName = programName == 'go-cyberchain' ? 'ccx' : programName;
  if (Platform.isWindows) {
    executableName = '$executableName.exe';
  }

  // Try different decoders
  try {
    archive = TarDecoder().decodeBytes(GZipDecoder().decodeBytes(bytes));
  } catch (e) {
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (e2) {
      throw Exception('Failed to decode archive: $e, $e2');
    }
  }

  // Find the executable
  final executableEntry = archive.files.firstWhere(
    (file) {
      final fileName = path.basename(file.name);
      return file.isFile && fileName == executableName;
    },
    orElse: () => throw Exception('Executable not found: $executableName'),
  );

  // Write executable to output directory
  final outputPath = path.join(outputDir, executableName);
  final outputFile = File(outputPath);

  await outputFile.writeAsBytes(executableEntry.content as List<int>);

  // Make executable on Unix-like systems
  if (!Platform.isWindows) {
    await Process.run('chmod', ['+x', outputPath]);
  }

  print('  Extracted to: $outputPath');
  return outputPath;
}

/// Download and extract a program
Future<void> downloadProgram(String program) async {
  print('\n=== Downloading $program ===');

  // Get latest version
  final version = await getLatestVersion(program);
  if (version == null) {
    print('  ERROR: Could not determine latest version');
    exit(1);
  }

  // Build download URL
  final platform = getPlatformString();
  final arch = getArchString();
  final extension = platform == 'windows' ? 'zip' : 'tar.gz';

  // URL program name is different for go-cyberchain
  final urlProgramName = program == 'go-cyberchain' ? 'ccx' : program;

  // Capitalize platform name for URL
  final platformCapitalized = platform[0].toUpperCase() + platform.substring(1);
  final archCapitalized = arch.toUpperCase();

  final downloadUrl =
      'https://github.com/cyberchainxyz/$program/releases/download/$version/$urlProgramName-$platformCapitalized-$archCapitalized-$version.$extension';

  // Setup directories
  final scriptDir = Directory.current;
  final assetsDir = path.join(scriptDir.path, 'assets', 'programs', program);
  final tempDir = path.join(scriptDir.path, '.temp_download');

  // Create directories
  await Directory(assetsDir).create(recursive: true);
  await Directory(tempDir).create(recursive: true);

  // Download archive
  final archivePath = path.join(tempDir, 'temp_archive.$extension');
  await downloadFile(downloadUrl, archivePath);

  // Extract executable
  await extractExecutable(archivePath, program, assetsDir);

  // Cleanup
  await File(archivePath).delete();
  await Directory(tempDir).delete(recursive: true);

  print('  ✓ Success! Program ready in assets/programs/$program');
}

/// Main function
Future<void> main(List<String> args) async {
  print('==============================================');
  print('CyberChain Desktop - Program Download Script');
  print('==============================================');
  print('Platform: ${getPlatformString()}');
  print('Architecture: ${getArchString()}');
  print('');

  final programs = ['go-cyberchain', 'xMiner'];

  for (final program in programs) {
    try {
      await downloadProgram(program);
    } catch (e) {
      print('  ERROR: Failed to download $program: $e');
      exit(1);
    }
  }

  print('\n==============================================');
  print('All programs downloaded successfully!');
  print('==============================================');
}
