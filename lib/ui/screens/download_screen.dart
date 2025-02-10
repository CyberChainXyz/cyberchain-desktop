import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/providers/app_state_provider.dart';
import '../../core/providers/service_providers.dart';
import '../../core/constants/app_constants.dart';
import '../../core/services/update_checker.dart';
import 'home_screen.dart';

class DownloadScreen extends ConsumerStatefulWidget {
  final bool fromHome;

  const DownloadScreen({
    super.key,
    this.fromHome = false,
  });

  @override
  ConsumerState<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends ConsumerState<DownloadScreen> {
  String? _error;
  Set<String> _downloadingPrograms = {};
  Map<String, String?> _localVersions = {};
  Map<String, String?> _latestVersions = {};
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkLocalVersions();
    _checkLatestVersions();

    final downloadProgress = ref.watch(downloadProgressProvider);
    if (downloadProgress.downloading.contains(AppConstants.goCyberchainRepo)) {
      setState(() {
        _downloadingPrograms.add(AppConstants.goCyberchainRepo);
      });
    }
    if (downloadProgress.downloading.contains(AppConstants.xMinerRepo)) {
      setState(() {
        _downloadingPrograms.add(AppConstants.xMinerRepo);
      });
    }
  }

  Future<void> _checkLocalVersions() async {
    try {
      final programInfoService = ref.read(programInfoServiceProvider);
      final programs = [AppConstants.goCyberchainRepo, AppConstants.xMinerRepo];

      for (final program in programs) {
        final info = await programInfoService.getProgramInfo(program);
        if (mounted) {
          setState(() {
            _localVersions[program] = info?.version;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to check local versions: $e';
        });
      }
    }
  }

  Future<void> _checkLatestVersions() async {
    setState(() {
      _isChecking = true;
    });

    try {
      final githubService = ref.read(githubServiceProvider);
      final programs = [AppConstants.goCyberchainRepo, AppConstants.xMinerRepo];

      for (final program in programs) {
        final latestVersion = await githubService.getLatestVersion(program);
        if (mounted) {
          setState(() {
            _latestVersions[program] = latestVersion;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to check latest versions: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  Future<void> _downloadProgram(String program) async {
    setState(() {
      _downloadingPrograms.add(program);
      _error = null;
    });

    try {
      final updateService = ref.read(updateServiceProvider.notifier);
      final downloadProgress = ref.read(downloadProgressProvider.notifier);
      final processService = ref.read(processServiceProvider.notifier);
      final downloadState = ref.read(downloadProgressProvider);

      // Stop the program before downloading
      try {
        if (processService.isProcessRunning(program)) {
          await processService.stopProgram(program);
        }
      } catch (e) {
        // Ignore error if program is not running or fails to stop
      }

      if (!downloadState.downloading.contains(program)) {
        downloadProgress.startDownload(program);

        try {
          await updateService.updateProgram(
            program,
            onProgress: (progress) {
              downloadProgress.updateProgress(program, progress);
            },
          );
        } finally {
          downloadProgress.finishDownload(program);
        }

        ref.read(programsUpdateProvider.notifier).checkUpdates();
      } else {
        while (downloadState.downloading.contains(program)) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      if (mounted) {
        // Update local version to latest version since we just downloaded it
        setState(() {
          _localVersions[program] = _latestVersions[program];
          _downloadingPrograms.remove(program);
        });

        // Only navigate to home screen if all programs are installed
        final allProgramsInstalled = [
          AppConstants.goCyberchainRepo,
          AppConstants.xMinerRepo
        ].every((p) => _localVersions[p] != null);

        if (allProgramsInstalled) {
          if (widget.fromHome) {
            Navigator.of(context).pop();
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Failed to download program: $e';
          _downloadingPrograms.remove(program);
        });
      }
    }
  }

  Widget _buildVersionInfo(String program) {
    final localVersion = _localVersions[program];
    final latestVersion = _latestVersions[program];
    final isUpToDate = localVersion != null && localVersion == latestVersion;
    final needsDownload = localVersion == null || localVersion != latestVersion;
    final isDownloading = _downloadingPrograms.contains(program);
    final downloadProgress = ref.watch(downloadProgressProvider);

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              program == AppConstants.goCyberchainRepo
                  ? 'go-cyberchain'
                  : 'xMiner',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Version',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey[600],
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        localVersion ?? 'Not installed',
                        style: TextStyle(
                          color: localVersion == null ? Colors.red : null,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                ),
                Expanded(
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Latest Version',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              latestVersion ?? 'Unknown',
                              style:
                                  const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      if (_isChecking)
                        const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      else if (isUpToDate)
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 24)
                      else if (!isDownloading)
                        SizedBox(
                          height: 36,
                          child: ElevatedButton.icon(
                            onPressed: needsDownload
                                ? () => _downloadProgram(program)
                                : null,
                            icon: const Icon(Icons.download, size: 18),
                            label: const Text('Download'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (isDownloading &&
                downloadProgress.downloading.contains(program)) ...[
              const SizedBox(height: 16),
              LinearProgressIndicator(
                value: downloadProgress.progress[program] ?? 0,
                backgroundColor: Colors.blue[50],
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[400]!),
              ),
              const SizedBox(height: 4),
              Text(
                '${((downloadProgress.progress[program] ?? 0) * 100).toStringAsFixed(1)}%',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                  });
                  _checkLocalVersions();
                  _checkLatestVersions();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: widget.fromHome
          ? AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  Navigator.of(context).pop();
                  ref.read(programsUpdateProvider.notifier).checkUpdates();
                },
              ),
            )
          : null,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue[50]!,
              Colors.white,
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            child: Container(
              width: 600,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Welcome to CyberChain',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[900],
                        ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'A Layer 1 blockchain with GPU-friendly PoW, built for the next generation of decentralized applications.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.grey[700],
                            height: 1.4,
                          ),
                    ),
                  ),
                  const SizedBox(height: 48),
                  _buildVersionInfo(AppConstants.goCyberchainRepo),
                  const SizedBox(height: 16),
                  _buildVersionInfo(AppConstants.xMinerRepo),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
