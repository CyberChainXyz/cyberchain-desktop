import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/service_providers.dart';
import 'core/services/app_notification_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/download_screen.dart';
import 'core/utils/user_agent_utils.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize User-Agent before any HTTP requests
  await UserAgentUtils.initialize();

  // Initialize notification service
  final notificationService = AppNotificationService();
  await notificationService.initialize();

  runApp(
    ProviderScope(
      overrides: [
        appNotificationServiceProvider.overrideWithValue(notificationService),
      ],
      child: const CCXDesktopApp(),
    ),
  );
}

final programExistsProvider = FutureProvider<bool>((ref) async {
  final initService = ref.read(initServiceProvider.notifier);
  return initService.checkProgramsExist();
});

class CCXDesktopApp extends ConsumerStatefulWidget {
  const CCXDesktopApp({super.key});

  @override
  ConsumerState<CCXDesktopApp> createState() => _CCXDesktopAppState();
}

class _CCXDesktopAppState extends ConsumerState<CCXDesktopApp> {
  late final AppLifecycleListener _listener;
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onExitRequested: _handleExitRequest,
    );
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  Future<AppExitResponse> _handleExitRequest() async {
    final processService = ref.read(processServiceProvider.notifier);
    final isGoCyberchainRunning =
        processService.isProcessRunning('go-cyberchain');
    final isXMinerRunning = processService.isProcessRunning('xMiner');

    if (isGoCyberchainRunning || isXMinerRunning) {
      final shouldExit = await showDialog<bool>(
        context: _navigatorKey.currentContext ?? context,
        barrierDismissible: false,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Confirm Exit'),
          content: Text(isXMinerRunning
              ? 'Mining processes are still running. Are you sure you want to exit?'
              : 'Node process is still running. Are you sure you want to exit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Exit'),
            ),
          ],
        ),
      );
      // debugPrint('shouldExit: $shouldExit');
      if (shouldExit != true) {
        return AppExitResponse.cancel;
      }

      // Stop mining processes before exit
      if (isGoCyberchainRunning) {
        // debugPrint('Stopping go-cyberchain');
        await processService.stopProgram('go-cyberchain');
      }
      if (isXMinerRunning) {
        // debugPrint('Stopping xMiner');
        await processService.stopProgram('xMiner');
      }
      // debugPrint('Exiting application');
    }

    return AppExitResponse.exit;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: _navigatorKey,
      title: 'CyberChain Desktop',
      debugShowCheckedModeBanner: false, // Hide the debug banner
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CCXDesktopHome(),
    );
  }
}

class CCXDesktopHome extends ConsumerWidget {
  const CCXDesktopHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programExists = ref.watch(programExistsProvider);

    return programExists.when(
      data: (exists) => exists ? const HomeScreen() : const DownloadScreen(),
      error: (error, _) => Scaffold(
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
              Text(error.toString()),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  ref.invalidate(programExistsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
      loading: () => const SizedBox.shrink(),
    );
  }
}
