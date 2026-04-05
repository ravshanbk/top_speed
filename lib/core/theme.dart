import 'package:flutter/material.dart';

class AppColors {
  static const background    = Color(0xFF080808);
  static const surface       = Color(0xFF111111);
  static const card          = Color(0xFF141414);
  static const border        = Color(0xFF222222);
  static const accent        = Color(0xFF00FF88);
  static const accel         = Color(0xFFFFAA00);
  static const danger        = Color(0xFFFF3B30);
  static const white         = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFF888888);
}

ThemeData buildAppTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.white,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent),
      ),
      hintStyle: const TextStyle(color: AppColors.textSecondary),
    ),
  );
}
