import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:backtix_app/src/app.dart';
import 'package:backtix_app/src/blocs/app_bloc_observer.dart';
import 'package:backtix_app/src/core/background_service.dart';
import 'package:backtix_app/src/core/local_notification.dart';
import 'package:backtix_app/src/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      await dotenv.load();

      WidgetsFlutterBinding.ensureInitialized();

      Bloc.observer = const AppBlocObserver();

      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getApplicationDocumentsDirectory(),
      );

      await Future.wait([
        ServiceLocator.initializeDependencies(),
        LocalNotification.init(),
      ]);
      await BackgroundService.init();

      /// for debugging on desktop
      if (kDebugMode &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        await windowManager.ensureInitialized();
        await windowManager.setAspectRatio(9 / 21);
        await windowManager.setAlwaysOnTop(true);
        await windowManager.setAlignment(Alignment.topRight);
      }

      App.run();
    },
    (error, stack) => log(error.toString(), stackTrace: stack),
  );
}
