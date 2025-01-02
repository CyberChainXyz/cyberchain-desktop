import 'dart:convert';
import 'package:http/http.dart' as http;

class GithubService {
  static const String _baseUrl = 'https://api.github.com/repos/cyberchainxyz';

  Future<String?> getLatestVersion(String program) async {
    final url = '$_baseUrl/$program/releases/latest';

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'CCX-Desktop-App',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final version = data['tag_name'] as String;
        return version;
      }
    } catch (e) {
      // No need to print error here, as it's handled in the catch block
    }

    try {
      final url = '$_baseUrl/$program/releases';
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'CCX-Desktop-App',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> releases = jsonDecode(response.body);
        if (releases.isNotEmpty) {
          final version = releases[0]['tag_name'] as String;
          return version;
        }
      }
    } catch (e) {
      // No need to print error here, as it's handled in the catch block
    }
    return null;
  }

  Future<bool> checkForUpdates(String program) async {
    final latestVersion = await getLatestVersion(program);
    return latestVersion != null;
  }
}
