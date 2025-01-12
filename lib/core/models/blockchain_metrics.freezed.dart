// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blockchain_metrics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$BlockchainMetrics {
  int get blockHeight => throw _privateConstructorUsedError;
  BigInt get difficulty => throw _privateConstructorUsedError;
  int get peerCount => throw _privateConstructorUsedError;

  /// Create a copy of BlockchainMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $BlockchainMetricsCopyWith<BlockchainMetrics> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $BlockchainMetricsCopyWith<$Res> {
  factory $BlockchainMetricsCopyWith(
          BlockchainMetrics value, $Res Function(BlockchainMetrics) then) =
      _$BlockchainMetricsCopyWithImpl<$Res, BlockchainMetrics>;
  @useResult
  $Res call({int blockHeight, BigInt difficulty, int peerCount});
}

/// @nodoc
class _$BlockchainMetricsCopyWithImpl<$Res, $Val extends BlockchainMetrics>
    implements $BlockchainMetricsCopyWith<$Res> {
  _$BlockchainMetricsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of BlockchainMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blockHeight = null,
    Object? difficulty = null,
    Object? peerCount = null,
  }) {
    return _then(_value.copyWith(
      blockHeight: null == blockHeight
          ? _value.blockHeight
          : blockHeight // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as BigInt,
      peerCount: null == peerCount
          ? _value.peerCount
          : peerCount // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$BlockchainMetricsImplCopyWith<$Res>
    implements $BlockchainMetricsCopyWith<$Res> {
  factory _$$BlockchainMetricsImplCopyWith(_$BlockchainMetricsImpl value,
          $Res Function(_$BlockchainMetricsImpl) then) =
      __$$BlockchainMetricsImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({int blockHeight, BigInt difficulty, int peerCount});
}

/// @nodoc
class __$$BlockchainMetricsImplCopyWithImpl<$Res>
    extends _$BlockchainMetricsCopyWithImpl<$Res, _$BlockchainMetricsImpl>
    implements _$$BlockchainMetricsImplCopyWith<$Res> {
  __$$BlockchainMetricsImplCopyWithImpl(_$BlockchainMetricsImpl _value,
      $Res Function(_$BlockchainMetricsImpl) _then)
      : super(_value, _then);

  /// Create a copy of BlockchainMetrics
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? blockHeight = null,
    Object? difficulty = null,
    Object? peerCount = null,
  }) {
    return _then(_$BlockchainMetricsImpl(
      blockHeight: null == blockHeight
          ? _value.blockHeight
          : blockHeight // ignore: cast_nullable_to_non_nullable
              as int,
      difficulty: null == difficulty
          ? _value.difficulty
          : difficulty // ignore: cast_nullable_to_non_nullable
              as BigInt,
      peerCount: null == peerCount
          ? _value.peerCount
          : peerCount // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$BlockchainMetricsImpl implements _BlockchainMetrics {
  const _$BlockchainMetricsImpl(
      {required this.blockHeight,
      required this.difficulty,
      required this.peerCount});

  @override
  final int blockHeight;
  @override
  final BigInt difficulty;
  @override
  final int peerCount;

  @override
  String toString() {
    return 'BlockchainMetrics(blockHeight: $blockHeight, difficulty: $difficulty, peerCount: $peerCount)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$BlockchainMetricsImpl &&
            (identical(other.blockHeight, blockHeight) ||
                other.blockHeight == blockHeight) &&
            (identical(other.difficulty, difficulty) ||
                other.difficulty == difficulty) &&
            (identical(other.peerCount, peerCount) ||
                other.peerCount == peerCount));
  }

  @override
  int get hashCode =>
      Object.hash(runtimeType, blockHeight, difficulty, peerCount);

  /// Create a copy of BlockchainMetrics
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$BlockchainMetricsImplCopyWith<_$BlockchainMetricsImpl> get copyWith =>
      __$$BlockchainMetricsImplCopyWithImpl<_$BlockchainMetricsImpl>(
          this, _$identity);
}

abstract class _BlockchainMetrics implements BlockchainMetrics {
  const factory _BlockchainMetrics(
      {required final int blockHeight,
      required final BigInt difficulty,
      required final int peerCount}) = _$BlockchainMetricsImpl;

  @override
  int get blockHeight;
  @override
  BigInt get difficulty;
  @override
  int get peerCount;

  /// Create a copy of BlockchainMetrics
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$BlockchainMetricsImplCopyWith<_$BlockchainMetricsImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
