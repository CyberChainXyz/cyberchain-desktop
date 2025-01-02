import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/program_info.dart';
import '../../shared/utils/platform_utils.dart';
import 'update_service.dart';
import 'program_info_service.dart';
import '../providers/app_state_provider.dart';

class InitService extends StateNotifier<bool> {
  final UpdateService _updateService;
  final ProgramInfoService _programInfoService;
  final DownloadProgressNotifier _downloadProgress;
  final List<String> _requiredPrograms = ['go-cyberchain', 'xMiner'];

  InitService(
    this._updateService,
    this._programInfoService,
    this._downloadProgress,
  ) : super(false);

  Future<bool> checkProgramsExist() async {
    try {
      print('Starting program existence check...');
      for (final programName in _requiredPrograms) {
        print('Checking if $programName exists...');
        final exists = await _programInfoService.programExists(programName);
        print('$programName exists: $exists');
        if (!exists) {
          print('$programName not found, returning false');
          return false;
        }
      }
      print('All programs exist, returning true');
      return true;
    } catch (e, stackTrace) {
      print('Error checking programs: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  Future<void> downloadPrograms() async {
    try {
      print('Starting program downloads...');
      for (final programName in _requiredPrograms) {
        print('Checking if $programName needs to be downloaded...');
        if (!await _programInfoService.programExists(programName)) {
          print('Starting download for $programName...');
          _downloadProgress.startDownload(programName);

          try {
            await _updateService.updateProgram(
              programName,
              onProgress: (progress) {
                print(
                    'Download progress for $programName: ${(progress * 100).toStringAsFixed(2)}%');
                _downloadProgress.updateProgress(programName, progress);
              },
            );
            print('Download completed for $programName');
          } catch (e) {
            print('Error downloading $programName: $e');
            rethrow;
          } finally {
            _downloadProgress.finishDownload(programName);
          }
        } else {
          print('$programName already exists, skipping download');
        }
      }
      print('All downloads completed successfully');
      state = true;
    } catch (e, stackTrace) {
      print('Error in downloadPrograms: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}
