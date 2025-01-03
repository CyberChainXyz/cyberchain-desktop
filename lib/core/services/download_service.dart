import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import '../models/program_info.dart';
import 'package:dio/dio.dart';
import '../../shared/utils/archive_utils.dart';

class DownloadService {
  final Dio _dio = Dio();
  static const String fallbackBaseUrl = 'https://file.cyberchain.xyz/fallback/';

  Future<String> downloadProgram(
    ProgramInfo program, {
    void Function(double)? onProgress,
    String? originalProgramName,
  }) async {
    final appDir = await getApplicationSupportDirectory();
    final programDir =
        Directory(path.join(appDir.path, originalProgramName ?? program.name));

    if (!programDir.existsSync()) {
      programDir.createSync(recursive: true);
    }

    // Download to a temporary archive file
    final archivePath = path.join(programDir.path, 'temp_archive');
    try {
      try {
        await _dio.download(
          program.downloadUrl,
          archivePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              onProgress
                  ?.call(progress * 0.8); // Use 80% of progress for download
            }
          },
        );
      } catch (e) {
        // If primary download fails, try fallback URL
        final fileName = path.basename(program.downloadUrl);
        final fallbackUrl = '$fallbackBaseUrl$fileName';

        await _dio.download(
          fallbackUrl,
          archivePath,
          onReceiveProgress: (received, total) {
            if (total != -1) {
              final progress = received / total;
              onProgress?.call(progress * 0.8);
            }
          },
        );
      }

      // Extract the executable from the archive
      final executablePath = await ArchiveUtils.extractExecutable(
        archivePath,
        program.name,
        originalProgramName: originalProgramName,
      );

      // Clean up the temporary archive file
      await File(archivePath).delete();

      return executablePath;
    } catch (e) {
      // Clean up the temporary archive file if it exists
      if (await File(archivePath).exists()) {
        await File(archivePath).delete();
      }
      rethrow;
    }
  }
}
