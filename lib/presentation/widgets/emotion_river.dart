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
    final activeMood = todayMood;
    return Container(
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          colors: recentMoods.isEmpty
              ? [AppColors.accentPurple.withValues(alpha: 0.15), AppColors.accentCyan.withValues(alpha: 0.08)]
              : recentMoods.map((m) => _moodColor(m).withValues(alpha: 0.2)).toList(),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        border: Border.all(color: AppColors.surfaceBorder),
        boxShadow: activeMood != null
            ? [
                BoxShadow(
                  color: _moodColor(activeMood).withValues(alpha: 0.12),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ]
            : null,
      ),
      child: Center(
        child: activeMood != null
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(activeMood.emoji, style: const TextStyle(fontSize: 34)),
                  const SizedBox(width: 10),
                  Text(
                    activeMood.label,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _moodColor(activeMood),
                      shadows: [
                        Shadow(
                          color: _moodColor(activeMood).withValues(alpha: 0.5),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                  ),
                ],
              )
            : const Text(
                '今天的心情是？',
                style: TextStyle(color: AppColors.textLabel, fontSize: 16),
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
