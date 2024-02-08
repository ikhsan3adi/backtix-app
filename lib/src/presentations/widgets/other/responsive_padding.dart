import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class ResponsivePadding extends StatelessWidget {
  const ResponsivePadding({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    EdgeInsets padding = EdgeInsets.zero;

    if (context.isDesktop) {
      padding = EdgeInsets.symmetric(horizontal: context.width / 6);
    } else if (context.isTablet) {
      padding = EdgeInsets.symmetric(horizontal: context.width / 8);
    }

    return Padding(padding: padding, child: child);
  }
}
