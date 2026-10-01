import 'dart:math';
import 'package:flutter/material.dart';
import '../tokens/app_tokens.dart';

/// LogoMark draws a clean vector pin with a sunrise inside using CustomPainter.
class LogoMark extends StatelessWidget {
  final double size;

  const LogoMark({super.key, this.size = 36.0});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(size * 0.33),
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.6, size * 0.6),
          painter: _LogoPainter(),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final goldPaint = Paint()
      ..color = AppTokens.gold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final fillPaint = Paint()
      ..color = AppTokens.gold
      ..style = PaintingStyle.fill;

    final width = size.width;
    final height = size.height;

    // Outer Pin shape
    final path = Path();
    path.moveTo(width * 0.5, height * 0.95);
    path.cubicTo(
      width * 0.1, height * 0.6,
      0, height * 0.45,
      width * 0.5, height * 0.05,
    );
    path.cubicTo(
      width, height * 0.45,
      width * 0.9, height * 0.6,
      width * 0.5, height * 0.95,
    );
    canvas.drawPath(path, goldPaint);

    // Inner Sunrise semicircle inside pin
    final center = Offset(width * 0.5, height * 0.45);
    final radius = width * 0.22;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi,
      pi,
      false,
      goldPaint,
    );

    // Center sun core
    canvas.drawCircle(center, radius * 0.4, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
