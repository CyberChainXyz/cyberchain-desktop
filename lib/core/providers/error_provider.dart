import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/error_handler.dart';

final errorHandlerProvider =
    StateNotifierProvider<ErrorHandler, Map<String, ErrorState>>((ref) {
  return ErrorHandler();
});
