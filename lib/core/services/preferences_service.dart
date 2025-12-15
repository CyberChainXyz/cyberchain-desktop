import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mining_pool.dart';

class PreferencesService {
  static const String _ccxAddressKey = 'ccx_address';
  static const String _selectedPoolKey = 'selected_pool';
  static const String _selectedDevicesKey = 'selected_devices';
  static const String _goCyberchainArgsKey = 'go_cyberchain_args';
  static const String _xMinerProxyKey = 'xminer_proxy';

  Future<void> saveCCXAddress(String address) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_ccxAddressKey, address);
  }

  Future<String?> loadCCXAddress() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_ccxAddressKey);
  }

  Future<void> saveSelectedPool(MiningPoolServer? pool) async {
    final prefs = await SharedPreferences.getInstance();
    if (pool == null) {
      await prefs.remove(_selectedPoolKey);
    } else {
      await prefs.setString(
          _selectedPoolKey, jsonEncode([pool.name, pool.url]));
    }
  }

  Future<MiningPoolServer?> loadSelectedPool() async {
    final prefs = await SharedPreferences.getInstance();
    final poolJson = prefs.getString(_selectedPoolKey);
    if (poolJson == null) return null;

    try {
      final List<dynamic> data = jsonDecode(poolJson);
      return MiningPoolServer(
        name: data[0] as String,
        url: data[1] as String,
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> saveSelectedDevices(Set<String> devices) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_selectedDevicesKey, devices.toList());
  }

  Future<Set<String>> loadSelectedDevices() async {
    final prefs = await SharedPreferences.getInstance();
    final devices = prefs.getStringList(_selectedDevicesKey);
    return devices?.toSet() ?? {};
  }

  Future<void> saveGoCyberchainArgs(List<String> args) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_goCyberchainArgsKey, args);
  }

  Future<List<String>> loadGoCyberchainArgs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_goCyberchainArgsKey) ?? [];
  }

  Future<void> saveXMinerProxy(String proxy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_xMinerProxyKey, proxy);
  }

  Future<String?> loadXMinerProxy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_xMinerProxyKey);
  }
}
