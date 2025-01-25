import 'package:flutter/material.dart';
import 'package:local_notifier/local_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

part 'app_notification_service.g.dart';

@Riverpod(keepAlive: true)
class NotificationSettings extends _$NotificationSettings {
  static const String _notificationEnabledKey = 'notification_enabled';

  @override
  bool build() {
    _loadNotificationSetting();
    return true;
  }

  Future<void> _loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_notificationEnabledKey) ?? true;
  }

  Future<void> toggle() async {
    state = !state;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationEnabledKey, state);
  }
}

@riverpod
AppNotificationService appNotificationService(AppNotificationServiceRef ref) {
  return AppNotificationService();
}

class AppNotificationService {
  Future<void> initialize() async {
    await localNotifier.setup(
      appName: 'CCX Desktop',
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
  }

  Future<void> showChatMessage({
    required String title,
    required String message,
    String? sender,
  }) async {
    final notification = LocalNotification(
      title: title,
      body: sender != null ? '$sender: $message' : message,
      actions: [LocalNotificationAction(text: 'Open')],
    );

    await notification.show();
  }

  Future<void> showNotification({
    required String title,
    required String message,
  }) async {
    final notification = LocalNotification(
      title: title,
      body: message,
      actions: [LocalNotificationAction(text: 'Open')],
    );

    await notification.show();
  }
}
