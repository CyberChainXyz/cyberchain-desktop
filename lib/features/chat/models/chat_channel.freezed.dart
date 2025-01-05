// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'chat_channel.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ChatChannel _$ChatChannelFromJson(Map<String, dynamic> json) {
  return _ChatChannel.fromJson(json);
}

/// @nodoc
mixin _$ChatChannel {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  /// Serializes this ChatChannel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ChatChannel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ChatChannelCopyWith<ChatChannel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ChatChannelCopyWith<$Res> {
  factory $ChatChannelCopyWith(
          ChatChannel value, $Res Function(ChatChannel) then) =
      _$ChatChannelCopyWithImpl<$Res, ChatChannel>;
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$ChatChannelCopyWithImpl<$Res, $Val extends ChatChannel>
    implements $ChatChannelCopyWith<$Res> {
  _$ChatChannelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ChatChannel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ChatChannelImplCopyWith<$Res>
    implements $ChatChannelCopyWith<$Res> {
  factory _$$ChatChannelImplCopyWith(
          _$ChatChannelImpl value, $Res Function(_$ChatChannelImpl) then) =
      __$$ChatChannelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      String description,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$ChatChannelImplCopyWithImpl<$Res>
    extends _$ChatChannelCopyWithImpl<$Res, _$ChatChannelImpl>
    implements _$$ChatChannelImplCopyWith<$Res> {
  __$$ChatChannelImplCopyWithImpl(
      _$ChatChannelImpl _value, $Res Function(_$ChatChannelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ChatChannel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? description = null,
    Object? createdAt = null,
  }) {
    return _then(_$ChatChannelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ChatChannelImpl implements _ChatChannel {
  const _$ChatChannelImpl(
      {required this.id,
      required this.name,
      required this.description,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$ChatChannelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ChatChannelImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String description;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'ChatChannel(id: $id, name: $name, description: $description, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ChatChannelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, id, name, description, createdAt);

  /// Create a copy of ChatChannel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ChatChannelImplCopyWith<_$ChatChannelImpl> get copyWith =>
      __$$ChatChannelImplCopyWithImpl<_$ChatChannelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ChatChannelImplToJson(
      this,
    );
  }
}

abstract class _ChatChannel implements ChatChannel {
  const factory _ChatChannel(
          {required final String id,
          required final String name,
          required final String description,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$ChatChannelImpl;

  factory _ChatChannel.fromJson(Map<String, dynamic> json) =
      _$ChatChannelImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get description;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;

  /// Create a copy of ChatChannel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ChatChannelImplCopyWith<_$ChatChannelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
