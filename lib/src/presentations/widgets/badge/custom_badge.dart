import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  const CustomBadge({
    super.key,
    required this.child,
    this.fillColor,
    this.borderColor,
    this.padding,
    this.margin,
    this.strokeWidth,
    this.borderRadius,
  });

  final Widget child;
  final Color? fillColor;
  final Color? borderColor;

  final double? strokeWidth;

  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 6,
            vertical: 3,
          ),
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: borderRadius ?? BorderRadius.circular(30),
        border: Border.all(
          width: strokeWidth ?? 1.5,
          color: borderColor ?? context.colorScheme.primary,
        ),
      ),
      child: child,
    );
  }
}
