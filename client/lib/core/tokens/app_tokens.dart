import 'package:flutter/material.dart';

/// Single source of truth for design system tokens (colors, radii, spacing, typography, motion).
/// Strictly complies with master.md Section 3.
abstract class AppTokens {
  // --- Section 3.1: Colour Tokens ---
  static const Color bg = Color(0xFFFDF8F4);
  static const Color surface = Color(0xFFF6ECE2);
  static const Color heroPeach = Color(0xFFF4E8D8);
  static const Color chip = Color(0xFFEDE6E1);
  static const Color border = Color(0xFFEBE1D0);
  static const Color ink = Color(0xFF2B2623);
  static const Color muted = Color(0xFF7A6F63);
  static const Color hint = Color(0xFFB9AE9F);
  static const Color gold = Color(0xFF8A6212);
  static const Color goldLine = Color(0xFFC9A04A);
  static const Color white = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF22C55E);

  // Template Card Pastels
  static const Color pastelPeach = Color(0xFFF6E9DD);
  static const Color pastelSage = Color(0xFFDFE6D6);
  static const Color pastelBlush = Color(0xFFF4DDD5);
  static const Color pastelIvory = Color(0xFFF3ECDD);

  // --- Section 3.3: Shape & Radii ---
  static const double radiusHeroCard = 24.0;
  static const double radiusTile = 16.0;
  static const double radiusButton = 16.0;
  static const double radiusInput = 16.0;
  static const double radiusBottomSheet = 28.0;
  static const double radiusPill = 999.0;

  // --- Section 3.3: Spacing (8pt grid) ---
  static const double space4 = 4.0;
  static const double space8 = 8.0;
  static const double space12 = 12.0;
  static const double space16 = 16.0;
  static const double space20 = 20.0;
  static const double space24 = 24.0;
  static const double space32 = 32.0;

  static const double screenPaddingHorizontal = 20.0;
  static const double sectionGap = 24.0;
  static const double buttonHeight = 56.0;

  // --- Motion ---
  static const Duration durationFast = Duration(milliseconds: 200);
  static const Duration durationStandard = Duration(milliseconds: 250);

  // --- Section 3.2: Typography & Font Families ---
  static const String fontDisplay = 'PlayfairDisplay';
  static const List<String> fontDisplayFallback = ['TiroDevanagariHindi'];

  static const String fontBody = 'PlusJakartaSans';
  static const List<String> fontBodyFallback = ['Hind'];

  // Title 28 - Playfair Display (400)
  static TextStyle get title28 => const TextStyle(
        fontFamily: fontDisplay,
        fontFamilyFallback: fontDisplayFallback,
        fontSize: 28.0,
        fontWeight: FontWeight.w400,
        color: ink,
        height: 1.25,
      );

  // Heading 22 - Playfair Display (500)
  static TextStyle get heading22 => const TextStyle(
        fontFamily: fontDisplay,
        fontFamilyFallback: fontDisplayFallback,
        fontSize: 22.0,
        fontWeight: FontWeight.w500,
        color: ink,
        height: 1.3,
      );

  // Body 14 - Plus Jakarta Sans (400)
  static TextStyle get body14 => const TextStyle(
        fontFamily: fontBody,
        fontFamilyFallback: fontBodyFallback,
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
        color: ink,
        height: 1.4,
      );

  // Body 14 Medium - Plus Jakarta Sans (500)
  static TextStyle get body14Medium => const TextStyle(
        fontFamily: fontBody,
        fontFamilyFallback: fontBodyFallback,
        fontSize: 14.0,
        fontWeight: FontWeight.w500,
        color: ink,
        height: 1.4,
      );

  // Small 12 - Plus Jakarta Sans (400)
  static TextStyle get small12 => const TextStyle(
        fontFamily: fontBody,
        fontFamilyFallback: fontBodyFallback,
        fontSize: 12.0,
        fontWeight: FontWeight.w400,
        color: muted,
        height: 1.4,
      );

  // Caption 11 - Plus Jakarta Sans (400) - Minimum 11sp rule enforced
  static TextStyle get caption11 => const TextStyle(
        fontFamily: fontBody,
        fontFamilyFallback: fontBodyFallback,
        fontSize: 11.0,
        fontWeight: FontWeight.w400,
        color: muted,
        height: 1.3,
      );
}
