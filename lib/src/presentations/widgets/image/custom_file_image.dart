import 'dart:io';

import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:flutter/material.dart';

class CustomFileImage extends StatelessWidget {
  const CustomFileImage({
    super.key,
    required this.file,
    this.small = false,
    this.fit = BoxFit.cover,
  });

  final File file;
  final bool small;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: FileImage(file),
      fit: fit,
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
