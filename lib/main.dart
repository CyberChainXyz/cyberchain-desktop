import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/providers/service_providers.dart';
import 'core/providers/version_provider.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/download_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: CCXDesktopApp(),
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
  @override
  void initState() {
    super.initState();
    // Trigger update check when app starts
    Future.delayed(Duration.zero, () {
      ref.read(hasUpdateProvider);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CCX Desktop',
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
