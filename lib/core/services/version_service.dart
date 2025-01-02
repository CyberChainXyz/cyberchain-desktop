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
    return packageInfo.version;
  }

  Future<String?> getLatestVersion() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final tagName = data['tag_name'] as String;
        _latestReleaseUrl = data['html_url'] as String;
        return tagName.startsWith('v') ? tagName.substring(1) : tagName;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  String? getLatestReleaseUrl() {
    return _latestReleaseUrl;
  }

  Future<bool> hasUpdate() async {
    final currentVersion = await getCurrentVersion();
    final latestVersion = await getLatestVersion();

    if (latestVersion == null) return false;

    final current = currentVersion.split('.').map(int.parse).toList();
    final latest = latestVersion.split('.').map(int.parse).toList();

    for (var i = 0; i < 3; i++) {
      if (latest[i] > current[i]) {
        return true;
      }
      if (latest[i] < current[i]) return false;
    }

    return false;
  }
}
