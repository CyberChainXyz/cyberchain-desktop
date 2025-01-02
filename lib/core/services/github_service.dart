import 'dart:convert';
import 'package:http/http.dart' as http;

class GithubService {
  static const String _baseUrl = 'https://api.github.com/repos/cyberchainxyz';

  Future<String?> getLatestVersion(String program) async {
    final url = '$_baseUrl/$program/releases/latest';
    print('Fetching latest version from: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'CCX-Desktop-App',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final version = data['tag_name'] as String;
        print('Latest version for $program: $version');
        return version;
      }
      print('Failed to get version. Status code: ${response.statusCode}');
    } catch (e) {
      print('Error getting latest version for $program: $e');
    }

    try {
      final url = '$_baseUrl/$program/releases';
      print('Trying to get version from all releases: $url');
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'CCX-Desktop-App',
        },
      );

      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final List<dynamic> releases = jsonDecode(response.body);
        if (releases.isNotEmpty) {
          final version = releases[0]['tag_name'] as String;
          print('Latest version from all releases for $program: $version');
          return version;
        }
      }
      print(
          'Failed to get version from all releases. Status code: ${response.statusCode}');
    } catch (e) {
      print('Error getting all releases for $program: $e');
    }
    return null;
  }

  Future<bool> checkForUpdates(String program) async {
    final latestVersion = await getLatestVersion(program);
    return latestVersion != null;
  }
}
