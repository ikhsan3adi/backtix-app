import 'package:backtix_app/src/blocs/theme_mode/theme_mode_cubit.dart';
import 'package:backtix_app/src/config/app_theme.dart';
import 'package:backtix_app/src/config/constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class App extends StatelessWidget {
  const App({super.key, required this.router, required this.appTheme});

  final RouterConfig<Object> router;
  final AppTheme appTheme;

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
