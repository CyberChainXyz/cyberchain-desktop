import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/notification.dart';
import '../../../core/utils/custom_http_client.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../providers/chat_provider.dart';
import '../../../core/services/app_notification_service.dart';

part 'notification_provider.freezed.dart';

@freezed
class NotificationState with _$NotificationState {
  const factory NotificationState({
    @Default([]) List<Notification> notifications,
    @Default(false) bool isLoading,
    String? error,
    String? userToken,
  }) = _NotificationState;
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier(ref);
});

class NotificationNotifier extends StateNotifier<NotificationState> {
  final Ref _ref;
  Timer? _timer;
  late final AppNotificationService _notificationService;
  bool _isFirstFetch = true;
  static const String _notificationsUrl = (kDebugMode && 1 == 0)
      ? 'http://127.0.0.1:8080/api/notifications'
      : 'https://chat.cyberchain.xyz/api/notifications';

  NotificationNotifier(this._ref)
      : _notificationService = _ref.read(appNotificationServiceProvider),
        super(const NotificationState()) {
    _init();
  }

  Future<void> _init() async {
    if (!mounted) return;
    await fetchNotifications();
    _startPolling();
  }

  void _startPolling() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: kDebugMode ? 10 : 600),
      (_) {
        fetchNotifications();
      },
    );
  }

  Future<void> fetchNotifications() async {
    if (!mounted) return;

    final currentUser = _ref.read(chatProvider).currentUser;
    if (currentUser == null) {
      state = state.copyWith(
        isLoading: false,
        error: 'User not found',
      );
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await getClient().get(
        Uri.parse(_notificationsUrl),
        headers: {
          'X-User-ID': currentUser.id,
          'X-Secret-Key': currentUser.secretKey,
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load notifications');
      }

      final NotificationResponse notificationResponse =
          NotificationResponse.fromJson(jsonDecode(response.body));

      if (!mounted) return;

      // Check for new notifications, but skip notifications on first fetch
      if (!_isFirstFetch) {
        final oldNotifications = state.notifications;
        final newNotifications = notificationResponse.notifications;

        // Show system notifications for new notifications
        final isEnabled = _ref.read(notificationSettingsProvider);
        if (isEnabled) {
          for (final notification in newNotifications) {
            if (!oldNotifications.any((n) => n.id == notification.id)) {
              _notificationService.showNotification(
                title: 'New Notification',
                message: notification.content,
              );
            }
          }
        }
      }

      _isFirstFetch = false;
      state = state.copyWith(
        notifications: notificationResponse.notifications,
        isLoading: false,
        userToken: notificationResponse.userToken,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
