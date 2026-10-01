import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_tokens.dart';

/// PrimaryButton: High-emphasis button (ink fill, bg text, 56 height, radius 16, light haptic).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool fullWidth;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leadingIcon,
    this.trailingIcon,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final childWidget = SizedBox(
      height: AppTokens.buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTokens.ink,
          foregroundColor: AppTokens.bg,
          disabledBackgroundColor: AppTokens.chip,
          disabledForegroundColor: AppTokens.muted,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTokens.radiusButton),
          ),
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.space24),
        ),
        onPressed: onPressed == null
            ? null
            : () {
                HapticFeedback.lightImpact();
                onPressed!();
              },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (leadingIcon != null) ...[
              Icon(leadingIcon, size: 20, color: AppTokens.bg),
              const SizedBox(width: AppTokens.space8),
            ],
            Text(
              label,
              style: AppTokens.body14Medium.copyWith(color: AppTokens.bg),
            ),
            if (trailingIcon != null) ...[
              const SizedBox(width: AppTokens.space8),
              Icon(trailingIcon, size: 20, color: AppTokens.bg),
            ],
          ],
        ),
      ),
    );

    if (fullWidth) {
      return SizedBox(width: double.infinity, child: childWidget);
    }
    return childWidget;
  }
}
