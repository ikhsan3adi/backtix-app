import 'package:backtix_app/src/core/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.src,
    this.small = false,
  });

  final String src;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      src,
      fit: BoxFit.cover,
      loadingBuilder: (_, child, loadingProgress) {
        if (loadingProgress != null) return const Shimmer();
        return child;
      },
      errorBuilder: (_, __, ___) {
        return Container(
          color: context.isDark ? Colors.grey[800] : Colors.grey[200],
          child: Center(child: ImageErrorWidget(small: small)),
        );
      },
    );
  }
}
