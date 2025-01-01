import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/program_info.dart';

class DownloadService {
  Future<String> downloadProgram(ProgramInfo program) async {
    final response = await http.get(Uri.parse(program.downloadUrl));

    if (response.statusCode != 200) {
      throw Exception('Failed to download ${program.name}');
    }

    final appDir = await getApplicationSupportDirectory();
    final programDir = Directory(path.join(appDir.path, program.name));

    if (!programDir.existsSync()) {
      programDir.createSync(recursive: true);
    }

    final filePath = path.join(programDir.path, program.name);
    final file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);

    // Make the file executable on Unix-like systems
    if (!Platform.isWindows) {
      await Process.run('chmod', ['+x', filePath]);
    }

    return filePath;
  }
}
