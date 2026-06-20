import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/model/mood_type.dart';

class EmotionRiver extends StatelessWidget {
  final MoodType? todayMood;
  final List<MoodType> recentMoods;

  const EmotionRiver({
    super.key,
    this.todayMood,
    this.recentMoods = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: recentMoods.isEmpty
              ? [AppColors.neonPurple.withValues(alpha: 0.3), AppColors.neonCyan.withValues(alpha: 0.15)]
              : recentMoods.map((m) => _moodColor(m).withValues(alpha: 0.35)).toList(),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(color: AppColors.glassBorder),
        boxShadow: [
          BoxShadow(
            color: (todayMood != null ? _moodColor(todayMood!) : AppColors.neonCyan).withValues(alpha: 0.15),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: todayMood != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(todayMood!.emoji, style: const TextStyle(fontSize: 32)),
                  const SizedBox(width: 8),
                  Text(todayMood!.label,
                    style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600,
                      color: _moodColor(todayMood!),
                    ),
                  ),
                ],
              )
            : const Text(
                '今天的心情是？',
                style: TextStyle(color: AppColors.textSoft, fontSize: 16),
              ),
      ),
    );
  }

  Color _moodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return AppColors.moodHappy;
      case MoodType.calm: return AppColors.moodCalm;
      case MoodType.longing: return AppColors.moodLonging;
      case MoodType.sad: return AppColors.moodSad;
      case MoodType.anxious: return AppColors.moodAnxious;
      case MoodType.hopeful: return AppColors.moodHopeful;
    }
  }
}
