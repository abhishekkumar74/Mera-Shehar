import 'package:flutter/material.dart';
import '../tokens/app_tokens.dart';

/// UserAvatar: Circular avatar with a 1.5px white outer ring. Shows initial if no photo.
class UserAvatar extends StatelessWidget {
  final String? photoPath;
  final String? initial;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.photoPath,
    this.initial,
    this.size = 36.0,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final avatarChild = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTokens.surface,
        border: Border.all(color: AppTokens.white, width: 1.5),
      ),
      child: ClipOval(
        child: Center(
          child: Text(
            (initial != null && initial!.isNotEmpty)
                ? initial![0].toUpperCase()
                : 'M',
            style: AppTokens.body14Medium.copyWith(
              color: AppTokens.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: avatarChild,
      );
    }
    return avatarChild;
  }
}
