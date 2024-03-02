import 'package:flutter/material.dart';

class ScannerOverlayPainter extends CustomPainter {
  const ScannerOverlayPainter({
    Color? color,
    this.strokeWidth = 6,
    this.radius = 20,
    this.length = 60,
  }) : _color = color ?? Colors.white;

  final Color _color;
  final double strokeWidth;
  final double radius;
  final double length;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    final rect = Rect.fromLTWH(
      strokeWidth,
      strokeWidth,
      size.width - (strokeWidth * 2),
      size.height - (strokeWidth * 2),
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final clippingRect0 = Rect.fromLTWH(0, 0, length, length);
    final clippingRect1 = Rect.fromLTWH(size.width - length, 0, length, length);
    final clippingRect2 =
        Rect.fromLTWH(0, size.height - length, length, length);
    final clippingRect3 = Rect.fromLTWH(
        size.width - length, size.height - length, length, length);

    final path = Path()
      ..addRect(clippingRect0)
      ..addRect(clippingRect1)
      ..addRect(clippingRect2)
      ..addRect(clippingRect3);

    canvas.clipPath(path);
    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
