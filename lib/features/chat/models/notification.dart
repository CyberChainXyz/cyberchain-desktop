import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification.freezed.dart';
part 'notification.g.dart';

@freezed
class NotificationAction with _$NotificationAction {
  const factory NotificationAction({
    required String label,
    required String link,
  }) = _NotificationAction;

  factory NotificationAction.fromJson(Map<String, dynamic> json) =>
      _$NotificationActionFromJson(json);
}

@freezed
class Notification with _$Notification {
  const factory Notification({
    required String id,
    required String title,
    required String content,
    required String type,
    required List<NotificationAction> actions,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _Notification;

  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);
}

@freezed
class NotificationResponse with _$NotificationResponse {
  const factory NotificationResponse({
    required List<Notification> notifications,
    @JsonKey(name: 'user_token') required String userToken,
  }) = _NotificationResponse;

  factory NotificationResponse.fromJson(Map<String, dynamic> json) =>
      _$NotificationResponseFromJson(json);
}
