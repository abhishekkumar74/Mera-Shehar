import 'package:flutter/material.dart';
import '../strings/app_strings.dart';
import '../tokens/app_tokens.dart';

/// AppBottomNav: 4 tabs with outline icons, sentence-case 11dp labels, active=ink, inactive=hint.
class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTokens.bg,
        border: Border(
          top: BorderSide(color: AppTokens.border, width: 1.0),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 60.0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _NavItem(
                label: AppStrings.tabHome,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                isActive: currentIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                label: AppStrings.tabTyohar,
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome,
                isActive: currentIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                label: AppStrings.tabSaved,
                icon: Icons.bookmark_border_outlined,
                activeIcon: Icons.bookmark,
                isActive: currentIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                label: AppStrings.tabProfile,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                isActive: currentIndex == 3,
                onTap: () => onTap(3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isActive ? AppTokens.ink : AppTokens.hint;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isActive ? activeIcon : icon,
            size: 22.0,
            color: color,
          ),
          const SizedBox(height: AppTokens.space4),
          Text(
            label,
            style: AppTokens.caption11.copyWith(
              color: color,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}
