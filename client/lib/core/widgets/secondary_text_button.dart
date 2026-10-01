import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../tokens/app_tokens.dart';

/// SecondaryTextButton: Low-emphasis text-only button (transparent fill, ink text).
class SecondaryTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const SecondaryTextButton({
    super.key,
    required this.label,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        foregroundColor: AppTokens.ink,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space12,
        ),
      ),
      onPressed: onPressed == null
          ? null
          : () {
              HapticFeedback.selectionClick();
              onPressed!();
            },
      child: Text(
        label,
        style: AppTokens.small12.copyWith(
          color: AppTokens.ink,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
