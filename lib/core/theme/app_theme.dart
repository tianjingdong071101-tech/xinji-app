import 'package:flutter/material.dart';
import 'app_colors.dart';

class XinjiTheme {
  XinjiTheme._();

  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.neonCyan,
        onPrimary: Colors.black,
        secondary: AppColors.neonPurple,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.textWhite,
      ),
      cardTheme: CardThemeData(
        color: AppColors.backgroundCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.glassBorder, width: 0.5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.neonCyan,
        foregroundColor: Colors.black,
        elevation: 8,
        shape: const CircleBorder(),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textWhite, letterSpacing: -0.5,
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
          fontSize: 12, color: AppColors.textSoft,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.backgroundDeep,
        selectedItemColor: AppColors.neonCyan,
        unselectedItemColor: AppColors.textSoft,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.backgroundCard,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.glassBorder),
        ),
        hintStyle: const TextStyle(color: AppColors.textSoft),
      ),
    );
  }
}
