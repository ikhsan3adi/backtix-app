import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;
  ColorScheme get colorScheme => theme.colorScheme;

  double get width => MediaQuery.of(this).size.width;
  double get height => MediaQuery.of(this).size.height;

  bool get isMobile => width < 768;
  bool get isTablet => width >= 768;
  bool get isDesktop => width >= 1024;

  T responsive<T>(
    T sm, {
    T? md,
    T? lg,
  }) {
    if (isDesktop) {
      return lg ?? md ?? sm;
    } else if (isTablet) {
      return md ?? sm;
    } else {
      return sm;
    }
  }
}
