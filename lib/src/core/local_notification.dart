import 'dart:async';

import 'package:backtix_app/src/config/constant.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  static final localNotification = FlutterLocalNotificationsPlugin();

  static final _responseStream =
      StreamController<NotificationResponse>.broadcast();

  static StreamSubscription<NotificationResponse> onResponse(
    Function(NotificationResponse) onData,
  ) {
    return _responseStream.stream.listen(onData);
  }

  static Future<void> init() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@drawable/ic_bg_service',
    );

    /// Not sure
    const initializationSettingsDarwin = DarwinInitializationSettings();
    final initializationSettingsLinux = LinuxInitializationSettings(
      defaultActionName: 'Open notification',
      defaultIcon: AssetsLinuxIcon('assets/icons/ic_launcher.png'),
    );

    final initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
      macOS: initializationSettingsDarwin,
      linux: initializationSettingsLinux,
    );

    await localNotification.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: onNotificationResponse,
    );
  }

  @pragma('vm:entry-point')
  static void onNotificationResponse(NotificationResponse response) {
    _responseStream.add(response);
  }

  static Future<void> show({
    required int id,
    String? title,
    String? body,
    String? payload,
  }) async {
    await localNotification.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  static NotificationDetails get notificationDetails {
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'notification_id',
      Constant.appName,
      icon: '@drawable/ic_bg_service',
      channelDescription: '${Constant.appName} notifications',
      importance: Importance.defaultImportance,
      priority: Priority.high,
      ticker: 'ticker',
    );
    DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      threadIdentifier: Constant.appName,
    );
    LinuxNotificationDetails linuxDetails = LinuxNotificationDetails(
      icon: AssetsLinuxIcon('assets/icons/ic_launcher.png'),
    );
    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
    );
  }
}
