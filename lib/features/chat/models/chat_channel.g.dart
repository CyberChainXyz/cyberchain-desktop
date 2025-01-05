// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_channel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatChannelImpl _$$ChatChannelImplFromJson(Map<String, dynamic> json) =>
    _$ChatChannelImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$ChatChannelImplToJson(_$ChatChannelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'created_at': instance.createdAt.toIso8601String(),
    };
