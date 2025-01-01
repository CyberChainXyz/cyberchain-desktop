import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/mining_pool.dart';

class GithubService {
  static const String _baseUrl = 'https://api.github.com/repos/CyberChainXyz';

  Future<String?> getLatestVersion(String program) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/$program/releases/latest'),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['tag_name'] as String;
    }
    return null;
  }

  Future<List<MiningPool>> getMiningPools() async {
    final response = await http.get(
      Uri.parse('$_baseUrl/CyberChainXyz.github.io/contents/pools.json'),
      headers: {'Accept': 'application/vnd.github.v3+json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final content = utf8.decode(base64.decode(data['content']));
      final List<dynamic> pools = jsonDecode(content);
      return pools.map((pool) => MiningPool.fromJson(pool)).toList();
    }
    return [];
  }

  Future<bool> checkForUpdates(String program) async {
    final latestVersion = await getLatestVersion(program);
    return latestVersion != null;
  }
}
