import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';

class ProcessOutput {
  final ListQueue<String> lines;
  final int maxLines;
  final int lastUpdate;

  ProcessOutput({
    ListQueue<String>? lines,
    this.maxLines = 500,
    this.lastUpdate = 0,
  }) : lines = lines ?? ListQueue<String>();

  ProcessOutput copyWith({
    ListQueue<String>? lines,
    int? maxLines,
    int? lastUpdate,
  }) {
    return ProcessOutput(
      lines: lines ?? this.lines,
      maxLines: maxLines ?? this.maxLines,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  String get fullOutput => lines.join('\n');

  List<String> get linesList => lines.toList();

  int get lineCount => lines.length;

  String? getLine(int index) {
    if (index >= 0 && index < lines.length) {
      return lines.elementAt(index);
    }
    return null;
  }

  List<String> search(String query) {
    if (query.isEmpty) return [];
    final lowercaseQuery = query.toLowerCase();
    return lines.where((line) => line.toLowerCase().contains(lowercaseQuery)).toList();
  }
}

class ProcessOutputNotifier extends StateNotifier<ProcessOutput> {
  ProcessOutputNotifier() : super(ProcessOutput());

  void appendOutput(String newOutput) {
    final newLines = newOutput.split('\n');
    final updatedLines = ListQueue<String>.from(state.lines);

    for (final line in newLines) {
      if (line.trim().isNotEmpty) {
        updatedLines.add(line);
        while (updatedLines.length > state.maxLines) {
          updatedLines.removeFirst();
        }
      }
    }

    state = state.copyWith(
      lines: updatedLines,
      lastUpdate: state.lastUpdate + 1,
    );
  }

  void clear() {
    state = ProcessOutput();
  }

  void setMaxLines(int maxLines) {
    final updatedLines = ListQueue<String>.from(state.lines);
    while (updatedLines.length > maxLines) {
      updatedLines.removeFirst();
    }
    state = state.copyWith(lines: updatedLines, maxLines: maxLines);
  }

  @override
  void dispose() {
    super.dispose();
  }
}

final goCyberchainOutputProvider =
    StateNotifierProvider<ProcessOutputNotifier, ProcessOutput>((ref) {
  return ProcessOutputNotifier();
});

final xMinerOutputProvider =
    StateNotifierProvider<ProcessOutputNotifier, ProcessOutput>((ref) {
  return ProcessOutputNotifier();
});
