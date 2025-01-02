import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_theme.dart';

final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.cyberpunk);

  void setTheme(AppThemeMode mode) {
    state = mode;
  }
}
