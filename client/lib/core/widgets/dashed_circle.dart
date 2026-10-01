import 'dart:math';
import 'package:flutter/material.dart';

/// DashedCirclePainter draws a dashed border ring around a circle.
class DashedCirclePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  DashedCirclePainter({
    required this.color,
    this.strokeWidth = 1.5,
    this.dashCount = 36,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    final sweepAngle = (2 * pi) / dashCount;

    for (int i = 0; i < dashCount; i += 2) {
      final startAngle = i * sweepAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle * 0.7,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
