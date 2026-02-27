import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import '../models/notification.dart' as notification_model;
import '../providers/notification_provider.dart';

class NotificationMarquee extends ConsumerStatefulWidget {
  const NotificationMarquee({super.key});

  @override
  ConsumerState<NotificationMarquee> createState() =>
      _NotificationMarqueeState();
}

class _NotificationMarqueeState extends ConsumerState<NotificationMarquee> {
  int _currentIndex = 0;
  Timer? _displayTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _scheduleNextNotification();
      }
    });
  }

  void _scheduleNextNotification() {
    _displayTimer?.cancel();
    _displayTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;

      final notifications = ref.read(notificationProvider).notifications;
      if (notifications.isEmpty) return;

      setState(() {
        _currentIndex = (_currentIndex + 1) % notifications.length;
      });
      _scheduleNextNotification();
    });
  }

  @override
  void didUpdateWidget(covariant NotificationMarquee oldWidget) {
    super.didUpdateWidget(oldWidget);
    final notifications = ref.read(notificationProvider).notifications;
    if (_currentIndex >= notifications.length) {
      setState(() {
        _currentIndex = notifications.isEmpty ? 0 : notifications.length - 1;
      });
    }
  }

  @override
  void dispose() {
    _displayTimer?.cancel();
    super.dispose();
  }

  void _showNotificationDialog(notification_model.Notification notification) {
    final notificationState = ref.read(notificationProvider);
    final userToken = notificationState.userToken;

    Uri _buildUrl(String baseUrl, {bool needToken = false}) {
      final uri = Uri.parse(baseUrl);
      if (!needToken || userToken == null) return uri;

      final queryParams = Map<String, String>.from(uri.queryParameters)
        ..['user_token'] = userToken;

      return uri.replace(queryParameters: queryParams);
    }

    if (notification.type == 'link') {
      launchUrl(
        _buildUrl(notification.content, needToken: notification.needToken),
        mode: LaunchMode.externalApplication,
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Container(
          width: 600,
          constraints: const BoxConstraints(maxHeight: 800),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 16, 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      offset: const Offset(0, 1),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        notification.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2D3843),
                          fontFamily: 'Inter',
                          fontFamilyFallback: ['Noto Color Emoji'],
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.close,
                        size: 20,
                        color: Color(0xFF95A5A6),
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 32,
                        minHeight: 32,
                      ),
                      splashRadius: 20,
                    ),
                  ],
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SelectableText(
                          notification.content,
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.5,
                            color: Color(0xFF2D3843),
                            fontFamily: 'Inter',
                            fontFamilyFallback: ['Noto Color Emoji'],
                          ),
                        ),
                        if (notification.actions.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          const Divider(height: 1),
                          const SizedBox(height: 24),
                          Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 12,
                              runSpacing: 12,
                              children: notification.actions.map((action) {
                                return ElevatedButton(
                                  onPressed: () {
                                    launchUrl(
                                      _buildUrl(action.link,
                                          needToken: action.needToken),
                                      mode: LaunchMode.externalApplication,
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
                                    foregroundColor: Colors.white,
                                    elevation: 0,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: Text(
                                    action.label,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: 'Inter',
                                      fontFamilyFallback: ['Noto Color Emoji'],
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notificationState = ref.watch(notificationProvider);
    final notifications = notificationState.notifications;

    if (notifications.isEmpty) {
      return const SizedBox.shrink();
    }

    if (_currentIndex >= notifications.length) {
      _currentIndex = 0;
    }

    final notification = notifications[_currentIndex];
    final isLink = notification.type == 'link';

    return Material(
      color: Colors.transparent,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 1),
                blurRadius: 3,
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              mouseCursor: SystemMouseCursors.click,
              onTap: () {
                _showNotificationDialog(notification);
              },
              hoverColor: const Color(0xFF2196F3).withOpacity(0.05),
              splashColor: const Color(0xFF2196F3).withOpacity(0.1),
              highlightColor: const Color(0xFF2196F3).withOpacity(0.05),
              child: Row(
                children: [
                  Icon(
                    isLink ? Icons.link : Icons.notifications_none,
                    size: 20,
                    color: const Color(0xFF95A5A6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      notification.title,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF2D3843),
                        fontFamily: 'Inter',
                        fontFamilyFallback: ['Noto Color Emoji'],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: const Color(0xFF95A5A6),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
