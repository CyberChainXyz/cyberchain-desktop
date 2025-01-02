import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/program_info.dart';
import 'package:dio/dio.dart';
import '../../shared/utils/archive_utils.dart';

class DownloadService {
  final Dio _dio = Dio();

  Future<String> downloadProgram(
    ProgramInfo program, {
    void Function(double)? onProgress,
    String? originalProgramName,
  }) async {
    print('Starting download for ${program.name} from ${program.downloadUrl}');

    final appDir = await getApplicationSupportDirectory();
    final programDir =
        Directory(path.join(appDir.path, originalProgramName ?? program.name));

    if (!programDir.existsSync()) {
      print('Creating directory: ${programDir.path}');
      programDir.createSync(recursive: true);
    }

    // Download to a temporary archive file
    final archivePath = path.join(programDir.path, 'temp_archive');
    try {
      await _dio.download(
        program.downloadUrl,
        archivePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final progress = received / total;
            print(
                'Download progress for ${program.name}: ${(progress * 100).toStringAsFixed(1)}%');
            onProgress
                ?.call(progress * 0.8); // Use 80% of progress for download
          }
        },
      );

      print('Download completed for ${program.name}, extracting...');
      print('Program directory: ${programDir.path}');

      // Extract the executable from the archive
      final executablePath = await ArchiveUtils.extractExecutable(
        archivePath,
        program.name,
        originalProgramName: originalProgramName,
      );

      print('Extraction completed for ${program.name}');
      onProgress?.call(1.0); // Set progress to 100% after extraction

      // Clean up the temporary archive file
      await File(archivePath).delete();

      return executablePath;
    } catch (e) {
      print('Error processing ${program.name}: $e');
      // Clean up the temporary archive file if it exists
      if (await File(archivePath).exists()) {
        await File(archivePath).delete();
      }
      rethrow;
    }
  }
}
