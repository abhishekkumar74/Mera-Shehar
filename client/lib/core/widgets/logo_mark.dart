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
      decoration: const BoxDecoration(
        color: AppTokens.surface,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomPaint(
          size: Size(size * 0.55, size * 0.55),
          painter: _LogoPainter(),
        ),
      ),
    );
  }
}

class _LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final width = size.width;
    final height = size.height;

    final pinPaint = Paint()
      ..color = AppTokens.ink
      ..style = PaintingStyle.fill;

    final goldPaint = Paint()
      ..color = AppTokens.gold
      ..style = PaintingStyle.fill;

    // Pin shape
    final path = Path();
    path.moveTo(width * 0.5, height);
    path.cubicTo(
      width * 0.1, height * 0.65,
      0, height * 0.45,
      0, height * 0.35,
    );
    path.arcToPoint(
      Offset(width, height * 0.35),
      radius: Radius.circular(width * 0.5),
      clockwise: true,
    );
    path.cubicTo(
      width, height * 0.45,
      width * 0.9, height * 0.65,
      width * 0.5, height,
    );
    canvas.drawPath(path, pinPaint);

    // Inner cutout hole inside pin head
    final innerCenter = Offset(width * 0.5, height * 0.35);
    final innerRadius = width * 0.25;
    final bgPaint = Paint()..color = AppTokens.surface;
    canvas.drawCircle(innerCenter, innerRadius, bgPaint);

    // Inner golden sunrise inside cutout
    canvas.drawArc(
      Rect.fromCircle(center: Offset(width * 0.5, height * 0.38), radius: innerRadius * 0.8),
      pi,
      pi,
      true,
      goldPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
