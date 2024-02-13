import 'package:flutter/material.dart';

class TicketClipper extends CustomClipper<Path> {
  final double holeRadius;
  final double top;

  TicketClipper({required this.holeRadius, required this.top});

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(0, 0)
      ..lineTo(0.0, top - holeRadius)
      ..arcToPoint(
        Offset(0, top),
        clockwise: true,
        radius: const Radius.circular(1),
      )
      ..lineTo(0.0, size.height)
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, top)
      ..arcToPoint(
        Offset(size.width, top - holeRadius),
        clockwise: true,
        radius: const Radius.circular(1),
      )
      ..lineTo(size.width, 0.0)
      ..close();
  }

  @override
  bool shouldReclip(TicketClipper oldClipper) => true;
}
