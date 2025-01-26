// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$appNotificationServiceHash() =>
    r'5be12ff5dac3793390f420c4acf21d94aeed8862';

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
