import 'dart:async';
import 'dart:io';

import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/data/services/background_notification_service.dart';
import 'package:backtix_app/src/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

class BackgroundService {
  static bool supported = Platform.isAndroid || Platform.isIOS;

  static const notificationChannelId = 'btx_notification_channel_id';
  static const foregroundNotificationId = 6969;

  static final service = FlutterBackgroundService();

  static Future start() async {
    if (supported && !(await service.isRunning())) {
      return await service.startService();
    }
  }

  static void stop() async => invoke('stop');

  static Stream<Map<String, dynamic>?>? on(String method) {
    if (supported) return service.on(method);
    return null;
  }

  static void invoke(String method, [Map<String, dynamic>? args]) {
    if (supported) return service.invoke(method, args);
  }

  static Future<void> init() async {
    if (supported) {
      await BackgroundNotificationService.init();
      await service.configure(
        androidConfiguration: AndroidConfiguration(
          onStart: onStart,
          autoStartOnBoot: false,
          autoStart: false,
          isForegroundMode: false,
          notificationChannelId: notificationChannelId,
          initialNotificationTitle: Constant.appName,
          initialNotificationContent: 'Notification service enabled',
          foregroundServiceNotificationId: foregroundNotificationId,
        ),
        iosConfiguration: IosConfiguration(
          autoStart: true,
          onForeground: onStart,
          onBackground: (s) {
            onStart(s);
            return true;
          },
        ),
      );
    }
  }

  @pragma('vm:entry-point')
  static void onStart(ServiceInstance service) async {
    // DartPluginRegistrant.ensureInitialized();
    debugPrint('BACKGROUND SERVICE STARTED');

    await dotenv.load();

    HydratedBloc.storage = await HydratedStorage.build(
      storageDirectory: await getApplicationDocumentsDirectory(),
    );

    final (repository, bloc) = await ServiceLocator.initNotificationService();

    final backgroundNotificationService = BackgroundNotificationService(
      repository,
    );

    final subscription = bloc.stream.listen((state) {
      debugPrint('BACKGROUND AUTH BLOC STATE CHANGED: ${state.runtimeType}');
      state.maybeMap(
        authenticated: (_) async => await BackgroundService.start(),
        orElse: () => BackgroundService.stop(),
      );
    });

    service.on('stop').listen((event) async {
      if (supported && (await BackgroundService.service.isRunning())) {
        debugPrint('BACKGROUND SERVICE STOPPED');
        await subscription.cancel();
        await bloc.close();
        backgroundNotificationService.dispose();
        await service.stopSelf();
      }
    });

    backgroundNotificationService.start(service);
  }
}
