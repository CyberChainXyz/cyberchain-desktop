import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mining_pool.dart';

class GithubService {
  static const String _baseUrl = 'https://api.github.com/repos/cyberchainxyz';
  static const List<List<dynamic>> defaultPools = [
    [
      "Solo",
      [
        ["Local", "ws://127.0.0.1:8546"]
      ]
    ],
    [
      "CoolPool",
      [
        ["Main", "ws://ccx.coolpool.top:14003"],
        ["EU", "ws://eu.coolpool.top:14003"],
        ["US", "ws://us.coolpool.top:14003"],
        ["ASIA", "ws://asia.coolpool.top:14003"]
      ]
    ]
  ];

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

  Future<List<MiningPool>> getMiningPools() async {
    final url = '$_baseUrl/cyberchainxyz.github.io/contents/pools.json';
    print('Fetching mining pools from: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'CCX-Desktop-App',
        },
      );

      print('Response status code: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = utf8.decode(base64.decode(data['content']));
        final List<dynamic> pools = jsonDecode(content);
        return pools
            .map((pool) => MiningPool.fromJson(pool as List<dynamic>))
            .toList();
      }
      print('Failed to get mining pools. Status code: ${response.statusCode}');
    } catch (e) {
      print('Error getting mining pools: $e');
    }
    return defaultPools.map((pool) => MiningPool.fromJson(pool)).toList();
  }

  Future<bool> checkForUpdates(String program) async {
    final latestVersion = await getLatestVersion(program);
    return latestVersion != null;
  }
}
