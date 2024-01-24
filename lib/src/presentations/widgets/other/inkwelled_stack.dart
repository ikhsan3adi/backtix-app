import 'package:flutter/material.dart';

class InkWelledStack extends StatelessWidget {
  const InkWelledStack({
    super.key,
    required this.children,
    this.onTap,
    this.alignment,
    this.fit,
  });

  final List<Widget> children;
  final VoidCallback? onTap;
  final AlignmentGeometry? alignment;
  final StackFit? fit;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: alignment ?? AlignmentDirectional.topStart,
      fit: fit ?? StackFit.loose,
      children: [
        ...children,
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(onTap: onTap),
          ),
        ),
      ],
    );
  }
}
