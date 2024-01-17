import 'package:flutter/material.dart';

class AppTheme {
  static const Color seedColor = Colors.lightBlueAccent;
  static const String fontFamily = 'Poppins';

  final ThemeData lightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
    useMaterial3: true,
    fontFamily: fontFamily,
  );

  late final ThemeData darkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
    ),
    brightness: Brightness.dark,
    useMaterial3: true,
    fontFamily: fontFamily,
  );
}
