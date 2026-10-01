import 'package:flutter/material.dart';
import '../tokens/app_tokens.dart';

/// AppChip: Full-pill chip (selected = ink fill, bg text; unselected = chip fill, muted text).
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppTokens.durationFast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTokens.ink : AppTokens.chip,
          borderRadius: BorderRadius.circular(AppTokens.radiusPill),
        ),
        child: Text(
          label,
          style: AppTokens.small12.copyWith(
            color: isSelected ? AppTokens.bg : AppTokens.muted,
            fontWeight: isSelected ? FontWeight.w500 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
