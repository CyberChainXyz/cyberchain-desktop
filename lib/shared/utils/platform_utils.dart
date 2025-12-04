import 'dart:ffi';
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
    if (Platform.isWindows) return 'Windows';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isLinux) return 'Linux';
    throw UnsupportedError('Unsupported platform');
  }

  static String getArchString() {
    final abi = Abi.current();
    return switch (abi) {
      Abi.macosArm64 => 'ARM64',
      Abi.linuxX64 || Abi.macosX64 || Abi.windowsX64 => 'X64',
      _ => throw UnsupportedError('Unsupported architecture: $abi'),
    };
  }
}
