import 'package:flutter/material.dart';

class DashedLinePainter extends CustomPainter {
  DashedLinePainter({
    Color? color,
    double? dashWidth,
    double? dashSpace,
    double? strokeWidth,
  })  : _color = color ?? Colors.grey,
        _dashWidth = dashWidth ?? 9,
        _dashSpace = dashSpace ?? 5,
        _strokeWidth = strokeWidth ?? 1;

  final Color _color;
  final double _dashWidth;
  final double _dashSpace;
  final double _strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = _color
      ..strokeWidth = _strokeWidth;

    for (double x = .0; x < size.width; x += _dashWidth + _dashSpace) {
      canvas.drawLine(Offset(x, 0), Offset(x + _dashWidth, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
