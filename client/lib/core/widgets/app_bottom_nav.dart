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
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 12.0, top: 4.0),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        height: 64.0,
        decoration: BoxDecoration(
          color: AppTokens.surface,
          borderRadius: BorderRadius.circular(32.0),
          border: Border.all(color: AppTokens.border, width: 1.0),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0C000000),
              blurRadius: 12.0,
              offset: Offset(0, 4),
            ),
          ],
        ),
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
    final color = isActive ? AppTokens.gold : AppTokens.hint;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.0),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 6.0),
        decoration: BoxDecoration(
          color: isActive ? AppTokens.gold.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                color: isActive ? AppTokens.ink : AppTokens.hint,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
