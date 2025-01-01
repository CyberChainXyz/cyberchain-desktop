import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/update_checker.dart';
import 'settings_controller.dart';
import '../../core/theme/theme_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final themeMode = ref.watch(themeProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Miner Threads'),
            subtitle: Text('Current: ${settings.minerThreads}'),
            trailing: const Icon(Icons.edit),
            onTap: () async {
              final result = await showDialog<int>(
                context: context,
                builder: (context) => ThreadCountDialog(
                  initialValue: settings.minerThreads,
                ),
              );
              if (result != null) {
                ref.read(settingsProvider.notifier).setMinerThreads(result);
              }
            },
          ),
          SwitchListTile(
            title: const Text('Auto-check Updates'),
            subtitle: const Text('Automatically check for program updates'),
            value: settings.autoCheckUpdates,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setAutoCheckUpdates(value);
              if (value) {
                ref.read(updateCheckerProvider.notifier).startChecking();
              }
            },
          ),
          SwitchListTile(
            title: const Text('Auto-start Mining'),
            subtitle: const Text('Start mining when application launches'),
            value: settings.autoStartMining,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setAutoStartMining(value);
            },
          ),
          ListTile(
            title: const Text('Check for Updates'),
            trailing: const Icon(Icons.system_update),
            onTap: () {
              ref.read(updateCheckerProvider.notifier).checkUpdates();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Checking for updates...'),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Theme'),
            subtitle: Text(_getThemeModeName(themeMode)),
            trailing: const Icon(Icons.brightness_6),
            onTap: () async {
              final result = await showDialog<ThemeMode>(
                context: context,
                builder: (context) => ThemeModeDialog(
                  currentMode: themeMode,
                ),
              );
              if (result != null) {
                ref.read(themeProvider.notifier).setThemeMode(result);
              }
            },
          ),
        ],
      ),
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}

class ThreadCountDialog extends StatefulWidget {
  final int initialValue;

  const ThreadCountDialog({
    super.key,
    required this.initialValue,
  });

  @override
  State<ThreadCountDialog> createState() => _ThreadCountDialogState();
}

class _ThreadCountDialogState extends State<ThreadCountDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Set Miner Threads'),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          labelText: 'Number of Threads',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            final value = int.tryParse(_controller.text);
            if (value != null && value > 0) {
              Navigator.pop(context, value);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}

class ThemeModeDialog extends StatelessWidget {
  final ThemeMode currentMode;

  const ThemeModeDialog({
    super.key,
    required this.currentMode,
  });

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: const Text('Select Theme'),
      children: [
        for (final mode in ThemeMode.values)
          SimpleDialogOption(
            onPressed: () => Navigator.pop(context, mode),
            child: Text(_getThemeModeName(mode)),
          ),
      ],
    );
  }

  String _getThemeModeName(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }
}
