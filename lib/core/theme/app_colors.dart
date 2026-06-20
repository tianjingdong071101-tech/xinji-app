import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Surface — dark saturated gradient per Aurora anchor
  static const Color surfaceDark = Color(0xFF0A0418);
  static const Color surfaceDeep = Color(0xFF1A0A30);
  static const Color surfaceMid = Color(0xFF150824);
  static const Color surfaceCard = Color(0x12FFFFFF);
  static const Color surfaceBorder = Color(0x20FFFFFF);

  // Text
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textSoft = Color(0xFFB0A0C8);
  static const Color textLabel = Color(0xFF7B6F99);

  // Accent
  static const Color accentCyan = Color(0xFF00F0FF);
  static const Color accentPurple = Color(0xFFA855F7);

  // Mood — each mood is an aurora color with neon quality
  static const Color moodHappy = Color(0xFFFFD700);
  static const Color moodCalm = Color(0xFF00F0FF);
  static const Color moodLonging = Color(0xFF667EEA);
  static const Color moodSad = Color(0xFFA855F7);
  static const Color moodAnxious = Color(0xFFFF3366);
  static const Color moodHopeful = Color(0xFF34D399);
}
