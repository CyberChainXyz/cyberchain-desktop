import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart';

class MigrationService {
  static Future<void> migrate() async {
    if (kIsWeb) return;

    try {
      // 1. Migrate Application Support Directory
      final newSupportDir = await getApplicationSupportDirectory();
      _migrateByRename(newSupportDir.path);
    } catch (e) {
      // Migration failed silently
    }
  }

  static void _migrateByRename(String newPath) {
    // Direct replacement: cyberchain -> opencyber
    final oldPath = newPath.replaceAll('cyberchain', 'opencyber');
    final oldDir = Directory(oldPath);

    // If the old directory exists, move it to the new location
    if (oldDir.existsSync()) {
      try {
        final newDir = Directory(newPath);
        if (newDir.existsSync()) {
          newDir.deleteSync(recursive: true);
        }
        oldDir.renameSync(newPath);
      } catch (e) {
        // If rename fails, we keep the old data where it is
      }
    }
  }
}
