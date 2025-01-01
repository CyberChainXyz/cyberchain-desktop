import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/models/mining_pool.dart';
import '../../core/providers/service_providers.dart';

final miningPoolsProvider = FutureProvider<List<MiningPool>>((ref) async {
  final githubService = ref.watch(githubServiceProvider);
  return githubService.getMiningPools();
});
