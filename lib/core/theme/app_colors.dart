import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color backgroundDark = Color(0xFF0F0A1E);
  static const Color backgroundDeep = Color(0xFF1A103C);
  static const Color backgroundCard = Color(0x14FFFFFF);
  static const Color glassBorder = Color(0x2FFFFFFF);

  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSoft = Color(0xFFB0A8C8);

  static const Color neonCyan = Color(0xFF00F0FF);
  static const Color neonPurple = Color(0xFFA855F7);
  static const Color neonGold = Color(0xFFFFD700);

  static const Color moodHappy = Color(0xFFFFD700);
  static const Color moodCalm = Color(0xFF00F0FF);
  static const Color moodLonging = Color(0xFF667EEA);
  static const Color moodSad = Color(0xFFA855F7);
  static const Color moodAnxious = Color(0xFFFF4D4D);
  static const Color moodHopeful = Color(0xFF34D399);

  static Color moodColor(int index) {
    const colors = [
      moodHappy, moodCalm, moodLonging,
      moodSad, moodAnxious, moodHopeful,
    ];
    return colors[index % colors.length];
  }
}
