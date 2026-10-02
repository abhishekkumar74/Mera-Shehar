import 'dart:math';
import 'package:flutter/material.dart';
import '../domain/template_model.dart';

/// Fallback vector background painter drawn in template palette when bg WebP asset is not provided.
class PlaceholderBackgroundPainter extends CustomPainter {
  final TemplatePalette palette;
  final String category;

  PlaceholderBackgroundPainter({
    required this.palette,
    required this.category,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = palette.bgColor;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final linePaint = Paint()
      ..color = palette.accent.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final center = Offset(size.width * 0.5, size.height * 0.20);

    if (category == 'diwali') {
      // Concentric glow rings
      canvas.drawCircle(center, size.width * 0.25, linePaint);
      canvas.drawCircle(center, size.width * 0.35, linePaint);

      // Line art diya
      final diyaPaint = Paint()
        ..color = palette.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final path = Path();
      path.moveTo(center.dx - 24, center.dy + 8);
      path.quadraticBezierTo(center.dx, center.dy + 32, center.dx + 24, center.dy + 8);
      path.close();
      canvas.drawPath(path, diyaPaint);

      // Flame
      final flamePath = Path();
      flamePath.moveTo(center.dx, center.dy + 4);
      flamePath.quadraticBezierTo(center.dx + 8, center.dy - 12, center.dx, center.dy - 24);
      flamePath.quadraticBezierTo(center.dx - 8, center.dy - 12, center.dx, center.dy + 4);
      flamePath.close();
      canvas.drawPath(flamePath, Paint()..color = palette.accent..style = PaintingStyle.fill);
    } else if (category == 'christmas') {
      // Minimal Pine Tree outline
      final pinePaint = Paint()
        ..color = palette.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final path = Path();
      path.moveTo(center.dx, center.dy - 30);
      path.lineTo(center.dx + 20, center.dy);
      path.lineTo(center.dx + 8, center.dy);
      path.lineTo(center.dx + 30, center.dy + 30);
      path.lineTo(center.dx - 30, center.dy + 30);
      path.lineTo(center.dx - 8, center.dy);
      path.lineTo(center.dx - 20, center.dy);
      path.close();
      canvas.drawPath(path, pinePaint);
    } else {
      // New Year Sparkles / Starbursts
      for (int i = 0; i < 8; i++) {
        final angle = i * (pi / 4);
        final dx = center.dx + cos(angle) * 30;
        final dy = center.dy + sin(angle) * 30;
        canvas.drawLine(center, Offset(dx, dy), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
