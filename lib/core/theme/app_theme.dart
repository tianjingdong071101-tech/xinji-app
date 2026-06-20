import 'package:flutter/material.dart';
import 'app_colors.dart';

class XinjiTheme {
  XinjiTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.surfaceDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.accentCyan,
        onPrimary: Colors.black,
        secondary: AppColors.accentPurple,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.textWhite,
      ),
      cardTheme: CardThemeData(
        color: AppColors.surfaceCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: AppColors.surfaceBorder.withValues(alpha: 0.3)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentCyan,
        foregroundColor: Colors.black,
        elevation: 12,
        shape: const CircleBorder(),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32, fontWeight: FontWeight.w800, color: AppColors.textWhite, letterSpacing: -1,
        ),
        headlineLarge: TextStyle(
          fontSize: 26, fontWeight: FontWeight.w700, color: AppColors.textWhite, letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textWhite,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, color: AppColors.textWhite, height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, color: AppColors.textSoft, height: 1.5,
        ),
        labelLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textWhite,
        ),
        labelSmall: TextStyle(
          fontSize: 12, color: AppColors.textLabel,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppColors.accentCyan,
        unselectedItemColor: AppColors.textLabel,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textWhite),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: AppColors.surfaceBorder.withValues(alpha: 0.3)),
        ),
        hintStyle: const TextStyle(color: AppColors.textLabel),
      ),
    );
  }
}
