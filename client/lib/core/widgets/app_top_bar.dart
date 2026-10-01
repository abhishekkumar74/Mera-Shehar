import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../strings/app_strings.dart';
import '../tokens/app_tokens.dart';
import 'logo_mark.dart';
import 'user_avatar.dart';

/// AppTopBar enforces the "single app bar per screen" rule (master.md Section 4.1).
class AppTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showLogoAndAvatar;
  final VoidCallback? onAvatarTap;

  const AppTopBar({
    super.key,
    this.title,
    this.showLogoAndAvatar = false,
    this.onAvatarTap,
  });

  /// Standard variant with logo mark + app name on left, avatar on right.
  factory AppTopBar.home({VoidCallback? onAvatarTap}) {
    return AppTopBar(
      showLogoAndAvatar: true,
      onAvatarTap: onAvatarTap,
    );
  }

  /// Title-only variant for Tyohar, Profile, Editor screens.
  factory AppTopBar.title(String title) {
    return AppTopBar(
      title: title,
      showLogoAndAvatar: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: title != null && Navigator.canPop(context),
      titleSpacing: AppTokens.screenPaddingHorizontal,
      title: showLogoAndAvatar
          ? Row(
              children: [
                const LogoMark(size: 36.0),
                const SizedBox(width: AppTokens.space12),
                GestureDetector(
                  onLongPress: () {
                    // Hidden entry point to debug design preview
                    context.push('/dev/design');
                  },
                  child: Text(
                    AppStrings.appName,
                    style: AppTokens.heading22,
                  ),
                ),
              ],
            )
          : Text(
              title ?? '',
              style: AppTokens.heading22,
            ),
      actions: showLogoAndAvatar
          ? [
              Padding(
                padding: const EdgeInsets.only(right: AppTokens.screenPaddingHorizontal),
                child: UserAvatar(
                  size: 36.0,
                  onTap: onAvatarTap ?? () => context.push('/profile'),
                ),
              ),
            ]
          : null,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
