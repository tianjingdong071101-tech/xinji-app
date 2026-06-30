import 'package:flutter/material.dart';

enum MoodType {
  happy('快乐', '☀️', Color(0xFFC08E3A)),
  calm('平静', '🌤', Color(0xFF8B9D83)),
  longing('思念', '🌧', Color(0xFFA0867A)),
  sad('忧伤', '🌨', Color(0xFF8B7B8B)),
  anxious('焦虑', '🌪', Color(0xFFC66B3D)),
  hopeful('期待', '🌈', Color(0xFF606C38));

  final String label;
  final String emoji;
  final Color color;

  const MoodType(this.label, this.emoji, this.color);
}
