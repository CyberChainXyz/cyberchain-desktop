import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorState {
  final String message;
  final bool isRetrying;
  final DateTime timestamp;

  ErrorState({
    required this.message,
    this.isRetrying = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

class ErrorHandler extends StateNotifier<Map<String, ErrorState>> {
  ErrorHandler() : super({});

  void handleError(String source, String message) {
    state = {
      ...state,
      source: ErrorState(message: message),
    };
  }

  void clearError(String source) {
    final newState = Map<String, ErrorState>.from(state);
    newState.remove(source);
    state = newState;
  }
}
