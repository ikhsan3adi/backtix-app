import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:backtix_app/src/app.dart';
import 'package:backtix_app/src/blocs/app_bloc_observer.dart';
import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/onboarding/onboarding_cubit.dart';
import 'package:backtix_app/src/blocs/theme_mode/theme_mode_cubit.dart';
import 'package:backtix_app/src/config/app_theme.dart';
import 'package:backtix_app/src/config/routes/app_route.dart';
import 'package:backtix_app/src/service_locator.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get_it/get_it.dart';
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

      await initializeDependencies();

      /// for debugging on desktop
      if (kDebugMode &&
          (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
        await windowManager.ensureInitialized();
        await windowManager.setAspectRatio(9 / 21);
        await windowManager.setAlwaysOnTop(true);
        await windowManager.setAlignment(Alignment.topRight);
      }

      final authBloc = GetIt.I<AuthBloc>();

      final router = AppRoute(authBloc: authBloc).goRouter;
      final appTheme = AppTheme();

      runApp(
        MultiBlocProvider(
          providers: [
            BlocProvider.value(
              value: authBloc..add(const AuthEvent.refreshAuthentication()),
            ),
            BlocProvider(
              create: (_) => GetIt.I<ThemeModeCubit>(),
            ),
            BlocProvider(
              create: (_) => GetIt.I<OnboardingCubit>(),
            ),
          ],
          child: App(router: router, appTheme: appTheme),
        ),
      );
    },
    (error, stack) => log(error.toString(), stackTrace: stack),
  );
}
