import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:collection';

class ProcessOutput {
  final Queue<String> lines;
  final int maxLines;

  ProcessOutput({
    Queue<String>? lines,
    this.maxLines = 500,
  }) : lines = lines ?? Queue<String>();

  ProcessOutput copyWith({
    Queue<String>? lines,
    int? maxLines,
  }) {
    return ProcessOutput(
      lines: lines ?? this.lines,
      maxLines: maxLines ?? this.maxLines,
    );
  }

  String get fullOutput => lines.join('\n');

  List<String> get linesList => lines.toList();

  int get lineCount => lines.length;

  String? getLine(int index) {
    final list = linesList;
    if (index >= 0 && index < list.length) {
      return list[index];
    }
    return null;
  }

  List<String> search(String query) {
    if (query.isEmpty) return [];
    final lowercaseQuery = query.toLowerCase();
    return linesList
        .where((line) => line.toLowerCase().contains(lowercaseQuery))
        .toList();
  }
}

class ProcessOutputNotifier extends StateNotifier<ProcessOutput> {
  ProcessOutputNotifier() : super(ProcessOutput());

  void appendOutput(String newOutput) {
    final newLines = newOutput.split('\n');
    final updatedLines = Queue<String>.from(state.lines);

    for (final line in newLines) {
      if (line.trim().isNotEmpty) {
        updatedLines.add(line);
        while (updatedLines.length > state.maxLines) {
          updatedLines.removeFirst();
        }
      }
    }

    state = state.copyWith(lines: updatedLines);
  }

  void clear() {
    state = ProcessOutput();
  }

  void setMaxLines(int maxLines) {
    final updatedLines = Queue<String>.from(state.lines);
    while (updatedLines.length > maxLines) {
      updatedLines.removeFirst();
    }
    state = ProcessOutput(lines: updatedLines, maxLines: maxLines);
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
