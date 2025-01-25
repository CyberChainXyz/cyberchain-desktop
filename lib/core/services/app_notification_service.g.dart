// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appNotificationServiceHash() =>
    r'0a97361903f4ad306f6b5e30762278a66e41d114';

/// See also [appNotificationService].
@ProviderFor(appNotificationService)
final appNotificationServiceProvider =
    AutoDisposeProvider<AppNotificationService>.internal(
  appNotificationService,
  name: r'appNotificationServiceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appNotificationServiceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppNotificationServiceRef
    = AutoDisposeProviderRef<AppNotificationService>;
String _$notificationSettingsHash() =>
    r'39aee8612a55e9affa73a2ef9a49ef937a90cb8d';

/// See also [NotificationSettings].
@ProviderFor(NotificationSettings)
final notificationSettingsProvider =
    NotifierProvider<NotificationSettings, bool>.internal(
  NotificationSettings.new,
  name: r'notificationSettingsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$notificationSettingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$NotificationSettings = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
