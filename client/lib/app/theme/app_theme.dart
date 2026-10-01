import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/tokens/app_tokens.dart';

/// AppTheme enforces the light, warm, editorial design system.
/// Dark mode is explicitly disabled in master.md.
abstract class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppTokens.bg,
      colorScheme: const ColorScheme.light(
        surface: AppTokens.bg,
        onSurface: AppTokens.ink,
        primary: AppTokens.ink,
        onPrimary: AppTokens.bg,
        secondary: AppTokens.gold,
        onSecondary: AppTokens.white,
        outline: AppTokens.border,
      ),
      splashColor: AppTokens.surface.withValues(alpha: 0.5),
      highlightColor: Colors.transparent,
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTokens.heading22,
        iconTheme: const IconThemeData(color: AppTokens.ink, size: 24),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark, // Dark icons on light bg
          statusBarBrightness: Brightness.light,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppTokens.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTokens.space16,
          vertical: AppTokens.space16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusInput),
          borderSide: const BorderSide(color: AppTokens.goldLine, width: 1.0),
        ),
        hintStyle: AppTokens.body14.copyWith(color: AppTokens.hint),
        labelStyle: AppTokens.body14.copyWith(color: AppTokens.muted),
      ),
      cardTheme: CardThemeData(
        color: AppTokens.bg,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusHeroCard),
          side: const BorderSide(color: AppTokens.border, width: 1.0),
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppTokens.white,
        surfaceTintColor: Colors.transparent,
        elevation: 4.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTokens.radiusBottomSheet),
          ),
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: AppTokens.border,
        thickness: 1.0,
        space: 1.0,
      ),
    );
  }
}
