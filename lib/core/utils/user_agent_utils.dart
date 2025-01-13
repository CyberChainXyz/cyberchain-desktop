import 'dart:io';
import 'package:package_info_plus/package_info_plus.dart';

class UserAgentUtils {
  static String? _cachedUserAgent;

  /// Initialize the User-Agent string. Must be called at app startup.
  static Future<void> initialize() async {
    if (_cachedUserAgent != null) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final platform = Platform.operatingSystem;
    final arch = Platform.version.contains('arm') ? 'arm64' : 'x64';

    _cachedUserAgent = 'ccx-desktop/$platform-$arch/${packageInfo.version}';
  }

  /// Get the User-Agent string. Must call initialize() first.
  static String getUserAgent() {
    if (_cachedUserAgent == null) {
      throw StateError(
          'UserAgentUtils not initialized. Call initialize() first.');
    }
    return _cachedUserAgent!;
  }
}
