import 'package:backtix_app/src/blocs/app_theme_mode/app_theme_mode_cubit.dart';
import 'package:backtix_app/src/config/app_theme.dart';
import 'package:backtix_app/src/config/routes/app_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    final router = AppRoute().goRouter;
    final appTheme = AppTheme();

    return BlocBuilder<AppThemeModeCubit, AppThemeModeState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: 'BackTix',
          theme: appTheme.lightTheme,
          darkTheme: appTheme.darkTheme,
          themeMode: state.when(
            light: () => ThemeMode.light,
            dark: () => ThemeMode.dark,
          ),
          routerConfig: router,
        );
      },
    );
  }
}
