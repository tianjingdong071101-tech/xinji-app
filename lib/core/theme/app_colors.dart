import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color sand = Color(0xFFE8DCC7);
  static const Color oat = Color(0xFFD4B895);
  static const Color cardWhite = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF8C8C8C);

  static const Color accentBrown = Color(0xFFC8956C);
  static const Color accentTerra = Color(0xFFC66B3D);

  static const Color moodHappy = Color(0xFFE8C170);
  static const Color moodCalm = Color(0xFFA0B8A0);
  static const Color moodLonging = Color(0xFF7BA7BC);
  static const Color moodSad = Color(0xFFB08BA0);
  static const Color moodAnxious = Color(0xFFC66B3D);
  static const Color moodHopeful = Color(0xFFA8C686);

  static Color moodColor(int index) {
    const colors = [
      moodHappy, moodCalm, moodLonging,
      moodSad, moodAnxious, moodHopeful,
    ];
    return colors[index % colors.length];
  }
}
