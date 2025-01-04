// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ChatMessageImpl _$$ChatMessageImplFromJson(Map<String, dynamic> json) =>
    _$ChatMessageImpl(
      id: json['id'] as String,
      senderId: json['senderId'] as String,
      senderName: json['senderName'] as String,
      senderAvatar: json['senderAvatar'] as String,
      content: json['content'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      version: (json['version'] as num?)?.toInt() ?? 1,
    );

Map<String, dynamic> _$$ChatMessageImplToJson(_$ChatMessageImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'senderId': instance.senderId,
      'senderName': instance.senderName,
      'senderAvatar': instance.senderAvatar,
      'content': instance.content,
      'timestamp': instance.timestamp.toIso8601String(),
      'type': _$MessageTypeEnumMap[instance.type]!,
      'version': instance.version,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.emoji: 'emoji',
};
