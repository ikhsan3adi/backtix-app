import 'dart:async';
import 'dart:math';

import 'package:backtix_app/src/config/app_theme.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/core/background_service.dart';
import 'package:backtix_app/src/core/local_notification.dart';
import 'package:backtix_app/src/data/models/notification/notification_model.dart';
import 'package:backtix_app/src/data/repositories/notification_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class BackgroundNotificationService {
  BackgroundNotificationService(this._repository);

  final NotificationRepository _repository;

  static final localNotification = LocalNotification.localNotification;

  Timer? _timer0;
  Timer? _timer1;
  DateTime? lastUpdated = DateTime.now();
  DateTime? lastUpdatedInfo = DateTime.now();

  static const updateMethod = 'update_notification';
  static const setDateMethod = 'setLastUpdated';

  void dispose() {
    _timer0?.cancel();
    _timer1?.cancel();
  }

  static Future<void> init() async {
    final channel = AndroidNotificationChannel(
      BackgroundService.notificationChannelId,
      '${Constant.appName} notification',
      description: 'This channel is used for important notifications.',
      importance: Importance.defaultImportance,
      ledColor: AppTheme.seedColor,
    );
    await localNotification
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  void start(ServiceInstance service) async {
    service.on(setDateMethod).listen((event) {
      debugPrint(event?.toString());
      lastUpdated = DateTime.tryParse(event?['lastUpdated']);
      lastUpdatedInfo = DateTime.tryParse(event?['lastUpdatedInfo']);
      run(service);
    });

    run(service);
  }

  void run(ServiceInstance service) async {
    debugPrint('BACKGROUND NOTIFICATION SERVICE STARTED');

    Duration importantInterval = Constant.shortInterval;
    Duration infoInterval = Constant.longInterval;

    _timer0 = Timer.periodic(importantInterval, (timer) async {
      try {
        final d = DateTime.now();
        final result = await _repository.getImportantNotifications(
          from: lastUpdated,
        );

        lastUpdated = d;

        debugPrint('UPDATED IMPORTANT NOTIFICATIONS: $lastUpdated');

        final notifications = result.toNullable() ?? [];
        showNotifications(notifications);

        service.invoke(
          updateMethod,
          {
            'last_updated': lastUpdated?.toIso8601String(),
            'important_notifications':
                notifications.map((e) => e.toJson()).toList(),
            'info_notifications': [],
          },
        );
      } catch (e) {
        debugPrint('UPDATED IMPORTANT NOTIFICATIONS ERROR: $e');
      }
    });

    _timer1 = Timer.periodic(infoInterval, (timer) async {
      try {
        final d = DateTime.now();
        final result = await _repository.getInfoNotifications(
          from: lastUpdatedInfo,
        );

        lastUpdatedInfo = d;

        debugPrint('UPDATED INFO NOTIFICATIONS: $lastUpdatedInfo');

        final notifications = result.toNullable() ?? [];
        showNotifications(notifications);

        service.invoke(
          updateMethod,
          {
            'info_last_updated': lastUpdatedInfo?.toIso8601String(),
            'important_notifications': [],
            'info_notifications': notifications.map((e) => e.toJson()).toList(),
          },
        );
      } catch (e) {
        debugPrint('UPDATED INFO NOTIFICATIONS ERROR: $e');
      }
    });
  }

  static final limit = Constant.notificationCountLimit;

  void showNotifications(List<NotificationModel> notifications) async {
    for (var n in notifications.take(limit)) {
      await LocalNotification.show(
        id: Random.secure().nextInt(6968),
        title: n.type.title,
        body: n.message,
        payload: '${n.id}',
      );
    }
  }
}
