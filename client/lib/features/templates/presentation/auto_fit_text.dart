import 'package:flutter/material.dart';

/// AutoFitText shrinks font size down to minFontSize to fit maxWidth, then wraps up to 3 lines. Never clips.
class AutoFitText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final double maxWidth;
  final double? minFontSize;
  final TextAlign align;
  final int maxLines;

  const AutoFitText({
    super.key,
    required this.text,
    required this.style,
    required this.maxWidth,
    this.minFontSize,
    this.align = TextAlign.center,
    this.maxLines = 3,
  });

  @override
  Widget build(BuildContext context) {
    final baseSize = style.fontSize ?? 14.0;
    final minSize = minFontSize ?? (baseSize * 0.60);

    return LayoutBuilder(
      builder: (context, constraints) {
        double currentSize = baseSize;
        TextStyle currentStyle = style.copyWith(fontSize: currentSize);

        while (currentSize > minSize) {
          final textPainter = TextPainter(
            text: TextSpan(text: text, style: currentStyle),
            textDirection: TextDirection.ltr,
            maxLines: maxLines,
            textAlign: align,
          )..layout(maxWidth: maxWidth);

          if (!textPainter.didExceedMaxLines && textPainter.width <= maxWidth) {
            break;
          }

          currentSize -= 1.0;
          currentStyle = style.copyWith(fontSize: currentSize);
        }

        return SizedBox(
          width: maxWidth,
          child: Text(
            text,
            style: currentStyle,
            textAlign: align,
            maxLines: maxLines,
            overflow: TextOverflow.ellipsis,
            softWrap: true,
          ),
        );
      },
    );
  }
}
