import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/widgets.dart';

class DashedDivider extends StatelessWidget {
  const DashedDivider({
    super.key,
    this.color,
    this.dashWidth,
    this.dashSpace,
    this.strokeWidth,
    this.margin,
  });

  final Color? color;
  final double? dashWidth;
  final double? dashSpace;
  final double? strokeWidth;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: CustomPaint(
        size: const Size.fromHeight(1),
        painter: DashedLinePainter(
          color: color ?? context.theme.dividerColor,
          dashWidth: dashWidth,
          dashSpace: dashSpace,
          strokeWidth: strokeWidth,
        ),
      ),
    );
  }
}
