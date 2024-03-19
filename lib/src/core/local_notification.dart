import 'dart:async';

import 'package:backtix_app/src/config/constant.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotification {
  static final localNotification = FlutterLocalNotificationsPlugin();

  static final _responseStream =
      StreamController<NotificationResponse>.broadcast();

  static Stream<NotificationResponse> get stream => _responseStream.stream;

  static Future<void> init() async {
    const initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    /// Not sure
    final initializationSettingsDarwin = DarwinInitializationSettings(
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        _responseStream.add(
          NotificationResponse(
            notificationResponseType:
                NotificationResponseType.selectedNotification,
            id: id,
            payload: payload,
          ),
        );
      },
    );
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
      channelDescription: '${Constant.appName} notifications',
      importance: Importance.defaultImportance,
      priority: Priority.high,
      ticker: 'ticker',
    );
    DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      threadIdentifier: Constant.appName,
    );
    const LinuxNotificationDetails linuxDetails = LinuxNotificationDetails();
    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
      linux: linuxDetails,
    );
  }
}
