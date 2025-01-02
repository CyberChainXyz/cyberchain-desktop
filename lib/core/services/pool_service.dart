import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import '../models/mining_pool.dart';

class PoolService {
  static const String poolsUrl = 'https://cyberchain.xyz/pools.json';
  static const String localFileName = 'pools.json';
  static const Duration fetchTimeout = Duration(seconds: 3);
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

  Future<String> get _localPath async {
    final directory = await getApplicationSupportDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$localFileName');
  }

  Future<List<MiningPool>> loadLocalPools() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return _parsePoolsJson(defaultPools);
      }
      final contents = await file.readAsString();
      final List<dynamic> json = jsonDecode(contents);
      return _parsePoolsJson(json);
    } catch (e) {
      return _parsePoolsJson(defaultPools);
    }
  }

  Future<void> saveLocalPools(List<MiningPool> pools) async {
    try {
      final file = await _localFile;
      final json = pools.map((pool) => pool.toJson()).toList();
      await file.writeAsString(jsonEncode(json));
    } catch (e) {
      // Silently handle error
    }
  }

  Future<List<MiningPool>> fetchPools() async {
    try {
      final client = http.Client();
      try {
        final response = await client
            .get(Uri.parse(poolsUrl))
            .timeout(fetchTimeout, onTimeout: () {
          throw TimeoutException('Fetch pools timeout');
        });

        if (response.statusCode == 200) {
          final List<dynamic> json = jsonDecode(response.body);
          final pools = _parsePoolsJson(json);
          await saveLocalPools(pools);
          return pools;
        }
      } finally {
        client.close();
      }
    } catch (e) {
      // Silently handle error
    }
    return loadLocalPools();
  }

  List<MiningPool> _parsePoolsJson(List<dynamic> json) {
    return json
        .map((pool) => MiningPool.fromJson(pool as List<dynamic>))
        .toList();
  }
}
