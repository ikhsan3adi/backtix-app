import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:backtix_app/src/app.dart';
import 'package:backtix_app/src/blocs/app_bloc_observer.dart';
import 'package:backtix_app/src/blocs/app_theme_mode/app_theme_mode_cubit.dart';
import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/service_locator.dart';
import 'package:dotenv/dotenv.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:window_manager/window_manager.dart';

Future<void> main() async {
  runZonedGuarded(
    () async {
      DotEnv().load();

      WidgetsFlutterBinding.ensureInitialized();

      Bloc.observer = const AppBlocObserver();

      HydratedBloc.storage = await HydratedStorage.build(
        storageDirectory: kIsWeb
            ? HydratedStorage.webStorageDirectory
            : await getApplicationDocumentsDirectory(),
      );

      await initializeDependencies();

      if (kDebugMode &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        await windowManager.ensureInitialized();
        await windowManager.setAspectRatio(9 / 21);
        await windowManager.setAlwaysOnTop(true);
        await windowManager.setAlignment(Alignment.topRight);
      }

      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (_) => GetIt.I<AppThemeModeCubit>(),
            ),
            BlocProvider(
              create: (_) => GetIt.I<AuthBloc>(),
            ),
          ],
          child: const App(),
        ),
      );
    },
    (error, stack) => log(error.toString(), stackTrace: stack),
  );
}