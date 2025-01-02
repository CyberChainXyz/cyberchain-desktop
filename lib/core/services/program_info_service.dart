import 'dart:convert';
import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/program_info.dart';

class ProgramInfoService {
  static const String _infoFileName = 'info.json';

  Future<String> _getProgramDir(String programName) async {
    final appDir = await getApplicationSupportDirectory();
    return path.join(appDir.path, programName);
  }

  Future<String> _getProgramInfoPath(String programName) async {
    final programDir = await _getProgramDir(programName);
    return path.join(programDir, _infoFileName);
  }

  Future<Map<String, ProgramInfo>> loadProgramInfo() async {
    final appDir = await getApplicationSupportDirectory();
    final programInfo = <String, ProgramInfo>{};

    try {
      if (!appDir.existsSync()) {
        return {};
      }

      // Get all subdirectories in the app directory
      final directories = appDir.listSync().whereType<Directory>();

      for (final dir in directories) {
        final programName = path.basename(dir.path);
        final info = await getProgramInfo(programName);
        if (info != null) {
          programInfo[programName] = info;
        }
      }

      return programInfo;
    } catch (e) {
      return {};
    }
  }

  Future<void> saveProgramInfo(Map<String, ProgramInfo> programInfo) async {
    try {
      for (final entry in programInfo.entries) {
        await updateProgramInfo(entry.key, entry.value);
      }
    } catch (e) {
      // Silently handle error
    }
  }

  Future<void> updateProgramInfo(String name, ProgramInfo info) async {
    try {
      final programDir = await _getProgramDir(name);
      final infoPath = await _getProgramInfoPath(name);

      // Create program directory if it doesn't exist
      final dir = Directory(programDir);
      if (!dir.existsSync()) {
        dir.createSync(recursive: true);
      }

      // Save program info
      final file = File(infoPath);
      final jsonString = jsonEncode(info.toJson());
      await file.writeAsString(jsonString);
    } catch (e) {
      // Silently handle error
    }
  }

  Future<ProgramInfo?> getProgramInfo(String name) async {
    try {
      final infoPath = await _getProgramInfoPath(name);
      final file = File(infoPath);

      if (!file.existsSync()) {
        return null;
      }

      final jsonString = await file.readAsString();
      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return ProgramInfo.fromJson(jsonMap);
    } catch (e) {
      return null;
    }
  }

  Future<bool> programExists(String name) async {
    final infoPath = await _getProgramInfoPath(name);
    return File(infoPath).existsSync();
  }
}
