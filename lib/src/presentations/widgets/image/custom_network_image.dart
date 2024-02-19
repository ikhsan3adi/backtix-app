import 'package:backtix_app/src/presentations/extensions/extensions.dart';
import 'package:backtix_app/src/presentations/widgets/widgets.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CustomNetworkImage extends StatelessWidget {
  const CustomNetworkImage({
    super.key,
    required this.src,
    this.small = false,
    this.fit = BoxFit.cover,
    this.cached = true,
  });

  final String src;
  final bool small;
  final BoxFit fit;
  final bool cached;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: cached
          ? CachedNetworkImageProvider(src)
          : NetworkImage(src) as ImageProvider,
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
