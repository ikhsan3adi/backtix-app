import 'package:backtix_app/src/blocs/auth/auth_bloc.dart';
import 'package:backtix_app/src/blocs/onboarding/onboarding_cubit.dart';
import 'package:backtix_app/src/blocs/theme_mode/theme_mode_cubit.dart';
import 'package:backtix_app/src/config/app_theme.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:backtix_app/src/config/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

class App extends StatelessWidget {
  const App({super.key, required this.router, required this.appTheme});

  final RouterConfig<Object> router;
  final AppTheme appTheme;

  static void run() {
    final authBloc = GetIt.I<AuthBloc>();

    final router = AppRoute(authBloc: authBloc).goRouter;
    final appTheme = AppTheme();

    return runApp(
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: authBloc),
          BlocProvider(create: (_) => GetIt.I<ThemeModeCubit>()),
          BlocProvider(create: (_) => GetIt.I<OnboardingCubit>()),
        ],
        child: App(router: router, appTheme: appTheme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeModeCubit, ThemeMode>(
      builder: (_, themeMode) {
        return MaterialApp.router(
          debugShowCheckedModeBanner: false,
          title: Constant.appName,
          theme: appTheme.lightTheme,
          darkTheme: appTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: router,
        );
      },
    );
  }
}
