import 'dart:io';
import 'package:flutter/material.dart';

import '../../../core/tokens/app_tokens.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../profile/data/profile_repository.dart';
import '../domain/template_model.dart';
import 'auto_fit_text.dart';
import 'placeholder_background_painter.dart';

/// CardView wraps CardRenderer in a FittedBox to scale the 360x450 canvas smoothly to any size.
class CardView extends StatelessWidget {
  final Template template;
  final UserProfile? profile;
  final PhotoLayout layout;
  final GlobalKey boundaryKey;
  final double? width;
  final double? height;

  const CardView({
    super.key,
    required this.template,
    required this.profile,
    required this.layout,
    required this.boundaryKey,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    Widget child = RepaintBoundary(
      key: boundaryKey,
      child: SizedBox(
        width: 360.0,
        height: 450.0,
        child: CardRenderer(
          template: template,
          profile: profile,
          layout: layout,
        ),
      ),
    );

    if (width != null || height != null) {
      return SizedBox(
        width: width,
        height: height,
        child: FittedBox(
          fit: BoxFit.contain,
          child: child,
        ),
      );
    }

    return FittedBox(
      fit: BoxFit.contain,
      child: child,
    );
  }
}

/// CardRenderer renders the 360x450 canvas according to master.md Section 5 & Phase 2 specs.
class CardRenderer extends StatelessWidget {
  final Template template;
  final UserProfile? profile;
  final PhotoLayout layout;

  const CardRenderer({
    super.key,
    required this.template,
    required this.profile,
    required this.layout,
  });

  @override
  Widget build(BuildContext context) {
    const canvasWidth = 360.0;
    const canvasHeight = 450.0;

    final bgAsset = template.backgroundAsset;
    final hasAsset = bgAsset != null && File(bgAsset).existsSync();

    return Semantics(
      label: 'Card: ${template.title}',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTokens.radiusHeroCard),
        child: Stack(
          children: [
            // Layer 1: Background Image or Placeholder Vector
            Positioned.fill(
              child: hasAsset
                  ? Image.file(
                      File(bgAsset),
                      width: canvasWidth,
                      height: canvasHeight,
                      fit: BoxFit.cover,
                    )
                  : CustomPaint(
                      size: const Size(canvasWidth, canvasHeight),
                      painter: PlaceholderBackgroundPainter(
                        palette: template.palette,
                        category: template.category,
                      ),
                    ),
            ),

            // Layer 2: Optional Inner Hairline Frame
            if (template.showInnerFrame)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      border: Border.all(
                        color: template.palette.frameColor ?? AppTokens.goldLine,
                        width: 1.0,
                      ),
                    ),
                  ),
                ),
              ),

            // Layer 3: Normalized Text Blocks
            ...template.texts.map((item) {
              final textWidth = canvasWidth * item.maxWidth;
              final left = (canvasWidth * item.x) - (textWidth / 2);
              final top = (canvasHeight * item.y) - 20;

              TextStyle textStyle;
              switch (item.style) {
                case 'eyebrow':
                  textStyle = AppTokens.caption11.copyWith(
                    color: item.color ?? template.palette.accent,
                    letterSpacing: 2.0,
                    fontWeight: FontWeight.w500,
                  );
                  break;
                case 'display':
                  textStyle = AppTokens.title28.copyWith(
                    color: item.color ?? template.palette.accent,
                    fontSize: item.fontSize ?? 34.0,
                    height: 1.35, // Generous Devanagari height
                  );
                  break;
                case 'italic':
                  textStyle = AppTokens.title28.copyWith(
                    fontStyle: FontStyle.italic,
                    color: item.color ?? template.palette.accent,
                    fontSize: item.fontSize ?? 16.0,
                  );
                  break;
                case 'body':
                default:
                  textStyle = AppTokens.body14.copyWith(
                    color: item.color ?? AppTokens.ink,
                    fontSize: item.fontSize ?? 13.0,
                    height: 1.35,
                  );
                  break;
              }

              return Positioned(
                left: left.clamp(10.0, canvasWidth - textWidth - 10.0),
                top: top.clamp(10.0, canvasHeight - 60.0),
                child: AutoFitText(
                  text: item.text,
                  style: textStyle,
                  maxWidth: textWidth,
                  minFontSize: item.minFontSize,
                  align: item.align,
                  maxLines: 3,
                ),
              );
            }),

            // Layer 4: Watermark ("Mera Shehar", 12 units from bottom, inside exported PNG)
            Positioned(
              bottom: 12.0,
              left: 0,
              right: 0,
              child: Center(
                child: Opacity(
                  opacity: 0.45,
                  child: Text(
                    'Mera Shehar',
                    style: AppTokens.caption11.copyWith(
                      fontSize: 10.0,
                      color: template.palette.pillText,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),

            // Layer 5: User Photo Pill
            _buildPhotoPill(context, canvasWidth, canvasHeight),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoPill(BuildContext context, double canvasWidth, double canvasHeight) {
    final name = profile?.name ?? 'User Name';
    final photoPath = profile?.photoPath;

    // Position coordinates
    double? left;
    double? right;
    double bottom = 36.0;

    switch (layout) {
      case PhotoLayout.bottomLeft:
        left = 24.0;
        break;
      case PhotoLayout.bottomRight:
        right = 24.0;
        break;
      case PhotoLayout.bottomCenter:
      case PhotoLayout.none:
      default:
        // Centered horizontally
        break;
    }

    final isNone = layout == PhotoLayout.none;

    final pillWidget = Container(
      height: 40.0,
      constraints: const BoxConstraints(maxWidth: 240.0),
      padding: EdgeInsets.only(
        left: isNone ? 14.0 : 6.0,
        right: 14.0,
        top: 4.0,
        bottom: 4.0,
      ),
      decoration: BoxDecoration(
        color: template.palette.pillBg.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(AppTokens.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!isNone) ...[
            UserAvatar(
              photoPath: photoPath,
              initial: profile?.firstName ?? 'M',
              size: 32.0,
            ),
            const SizedBox(width: AppTokens.space8),
          ],
          Flexible(
            child: Text(
              name,
              style: AppTokens.body14Medium.copyWith(
                color: template.palette.pillText,
                fontSize: 13.0,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

    if (left != null || right != null) {
      return Positioned(
        left: left,
        right: right,
        bottom: bottom,
        child: pillWidget,
      );
    }

    // Centered pill
    return Positioned(
      bottom: bottom,
      left: 0,
      right: 0,
      child: Center(child: pillWidget),
    );
  }
}
