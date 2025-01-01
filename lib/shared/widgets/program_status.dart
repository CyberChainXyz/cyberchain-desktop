import 'package:flutter/material.dart';
import '../../core/models/program_info.dart';

class ProgramStatus extends StatelessWidget {
  final ProgramInfo program;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onUpdate;
  final bool hasUpdate;

  const ProgramStatus({
    super.key,
    required this.program,
    required this.onStart,
    required this.onStop,
    required this.onUpdate,
    required this.hasUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  program.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (hasUpdate)
                  TextButton.icon(
                    onPressed: onUpdate,
                    icon: const Icon(Icons.system_update),
                    label: const Text('Update Available'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Version: ${program.version}'),
            const SizedBox(height: 16),
            Row(
              children: [
                ElevatedButton(
                  onPressed: program.isRunning ? onStop : onStart,
                  child: Text(program.isRunning ? 'Stop' : 'Start'),
                ),
                const SizedBox(width: 8),
                if (program.isRunning)
                  const CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
