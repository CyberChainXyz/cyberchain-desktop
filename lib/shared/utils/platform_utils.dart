import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class PlatformUtils {
  static Future<String> getAppDataPath() async {
    final appDir = await getApplicationSupportDirectory();
    return appDir.path;
  }

  static String getProgramFileName(String programName) {
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

  static Future<String> getProgramPath(String programName) async {
    final appDataPath = await getAppDataPath();
    final fileName = getProgramFileName(programName);
    return path.join(appDataPath, programName, fileName);
  }

  static String getPlatformString() {
    if (Platform.isWindows) return 'windows';
    if (Platform.isMacOS) return 'darwin';
    if (Platform.isLinux) return 'linux';
    throw UnsupportedError('Unsupported platform');
  }

  static String getArchString() {
    return Platform.version.contains('x64') ? 'amd64' : 'arm64';
  }
}
