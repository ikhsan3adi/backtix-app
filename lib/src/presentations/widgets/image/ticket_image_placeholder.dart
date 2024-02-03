import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class TicketImagePlaceholder extends StatelessWidget {
  const TicketImagePlaceholder({
    super.key,
    this.width = 80,
    this.height = 80,
  });

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/images/logo.svg',
      width: width,
      height: height,
    );
  }
}
