import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:package_info_plus/package_info_plus.dart';

class VersionService {
  static const String githubUrl =
      'https://github.com/CyberChainXyz/ccx-desktop/';
  static const String apiUrl =
      'https://api.github.com/repos/CyberChainXyz/ccx-desktop/releases/latest';

  String? _latestReleaseUrl;

  Future<String> getCurrentVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    print('Current version: ${packageInfo.version}');
    return packageInfo.version;
  }

  Future<String?> getLatestVersion() async {
    try {
      print('Fetching latest version from GitHub...');
      final response = await http.get(Uri.parse(apiUrl));
      print('API Response status: ${response.statusCode}');
      print('API Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tagName = data['tag_name'] as String;
        _latestReleaseUrl = data['html_url'] as String;
        print('Latest version: $tagName');
        print('Release URL: $_latestReleaseUrl');
        return tagName.startsWith('v') ? tagName.substring(1) : tagName;
      } else {
        print('Error checking for updates: ${response.statusCode}');
        print('Error response: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Error checking for updates: $e');
      return null;
    }
  }

  String? getLatestReleaseUrl() {
    print('Getting release URL: $_latestReleaseUrl');
    return _latestReleaseUrl;
  }

  Future<bool> hasUpdate() async {
    final currentVersion = await getCurrentVersion();
    final latestVersion = await getLatestVersion();

    if (latestVersion == null) return false;

    print(
        'Comparing versions - Current: $currentVersion, Latest: $latestVersion');

    final current = currentVersion.split('.').map(int.parse).toList();
    final latest = latestVersion.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      if (latest[i] > current[i]) {
        print('Update available: $currentVersion -> $latestVersion');
        return true;
      }
      if (latest[i] < current[i]) return false;
    }

    return false;
  }
}
