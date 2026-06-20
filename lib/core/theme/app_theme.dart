import 'package:flutter/material.dart';
import 'app_colors.dart';

class XinjiTheme {
  XinjiTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.sand,
      colorScheme: ColorScheme.light(
        primary: AppColors.accentBrown,
        onPrimary: AppColors.cardWhite,
        secondary: AppColors.accentTerra,
        surface: AppColors.cardWhite,
        onSurface: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentBrown,
        foregroundColor: AppColors.cardWhite,
        shape: const CircleBorder(),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.normal, color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, color: AppColors.textPrimary, height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, color: AppColors.textSecondary, height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 12, color: AppColors.textSecondary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardWhite,
        selectedItemColor: AppColors.accentBrown,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }
}
