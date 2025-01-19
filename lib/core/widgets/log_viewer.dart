import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../providers/output_providers.dart';

class LogViewer extends HookConsumerWidget {
  final ProcessOutput output;
  final bool isRunning;
  final String emptyMessage;
  final bool autoScroll;

  const LogViewer({
    super.key,
    required this.output,
    required this.isRunning,
    this.emptyMessage = 'No output',
    this.autoScroll = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scrollController = useScrollController();

    // Auto scroll to bottom when new content is added
    useEffect(() {
      if (!autoScroll) return null;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (scrollController.hasClients && output.lineCount > 0) {
          scrollController.animateTo(
            scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
      return null;
    }, [output.lineCount]);

    if (output.lineCount == 0) {
      return Center(
        child: Text(
          isRunning ? 'Starting program...' : emptyMessage,
          style: const TextStyle(
            color: Colors.white70,
            fontStyle: FontStyle.italic,
          ),
        ),
      );
    }

    return RawScrollbar(
      controller: scrollController,
      thumbVisibility: true,
      trackVisibility: true,
      thickness: 12,
      thumbColor: Colors.grey[600],
      radius: const Radius.circular(4),
      child: ListView.builder(
        controller: scrollController,
        itemCount: output.lineCount,
        itemBuilder: (context, index) {
          final line = output.getLine(index);
          if (line == null) return const SizedBox.shrink();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '>>',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              Container(
                width: 1,
                height: 16,
                color: Colors.grey[800],
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: SelectableText(
                  line,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
