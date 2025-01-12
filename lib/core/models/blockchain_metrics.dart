import 'package:freezed_annotation/freezed_annotation.dart';

part 'blockchain_metrics.freezed.dart';

@freezed
class BlockchainMetrics with _$BlockchainMetrics {
  const factory BlockchainMetrics({
    required int blockHeight,
    required BigInt difficulty,
    required int peerCount,
  }) = _BlockchainMetrics;
}
