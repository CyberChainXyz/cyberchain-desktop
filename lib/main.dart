import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/services/init_service.dart';
import 'core/providers/app_state_provider.dart';
import 'core/services/update_checker.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'core/providers/error_provider.dart';
import 'shared/widgets/loading_screen.dart';
import 'features/mining/mining_page.dart';

void main() async {
  runApp(const ProviderScope(child: CCXDesktopApp()));
}

class CCXDesktopApp extends ConsumerStatefulWidget {
  const CCXDesktopApp({super.key});

  @override
  ConsumerState<CCXDesktopApp> createState() => _CCXDesktopAppState();
}

class _CCXDesktopAppState extends ConsumerState<CCXDesktopApp> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final initService = ref.read(initServiceProvider);
      await initService.initialize();

      ref.read(updateCheckerProvider.notifier).startChecking();
      ref.read(appStateProvider.notifier).setInitialized();
    } catch (e) {
      ref.read(errorHandlerProvider.notifier).handleError(
            'initialization',
            'Failed to initialize: $e',
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appStateProvider);
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'CCX Desktop',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: appState.isInitialized
          ? const MiningPage()
          : const LoadingScreen(message: 'Initializing CCX Desktop...'),
    );
  }
}
