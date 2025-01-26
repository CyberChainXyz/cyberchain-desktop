// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$NotificationActionImpl _$$NotificationActionImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationActionImpl(
      label: json['label'] as String,
      link: json['link'] as String,
      needToken: json['need_token'] as bool? ?? false,
    );

Map<String, dynamic> _$$NotificationActionImplToJson(
        _$NotificationActionImpl instance) =>
    <String, dynamic>{
      'label': instance.label,
      'link': instance.link,
      'need_token': instance.needToken,
    };

_$NotificationImpl _$$NotificationImplFromJson(Map<String, dynamic> json) =>
    _$NotificationImpl(
      id: json['id'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      type: json['type'] as String,
      actions: (json['actions'] as List<dynamic>)
          .map((e) => NotificationAction.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
      needToken: json['need_token'] as bool? ?? false,
    );

Map<String, dynamic> _$$NotificationImplToJson(_$NotificationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'content': instance.content,
      'type': instance.type,
      'actions': instance.actions,
      'created_at': instance.createdAt.toIso8601String(),
      'need_token': instance.needToken,
    };

_$NotificationResponseImpl _$$NotificationResponseImplFromJson(
        Map<String, dynamic> json) =>
    _$NotificationResponseImpl(
      notifications: (json['notifications'] as List<dynamic>)
          .map((e) => Notification.fromJson(e as Map<String, dynamic>))
          .toList(),
      userToken: json['user_token'] as String,
    );

Map<String, dynamic> _$$NotificationResponseImplToJson(
        _$NotificationResponseImpl instance) =>
    <String, dynamic>{
      'notifications': instance.notifications,
      'user_token': instance.userToken,
    };
