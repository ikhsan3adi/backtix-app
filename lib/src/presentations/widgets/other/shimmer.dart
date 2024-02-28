import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart' as s;

class Shimmer extends StatelessWidget {
  const Shimmer({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return s.Shimmer.fromColors(
      baseColor: Colors.grey[isDark ? 800 : 400]!,
      highlightColor: Colors.grey[isDark ? 700 : 300]!,
      child: child ??
          Container(
            color: Colors.grey[500]!,
            width: double.infinity,
            height: double.infinity,
          ),
    );
  }
}
