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
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: recentMoods.isEmpty
              ? [AppColors.oat, AppColors.sand]
              : recentMoods.map(_moodColor).toList(),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Center(
        child: todayMood != null
            ? Text(todayMood!.emoji, style: const TextStyle(fontSize: 36))
            : FittedBox(
                child: Text(
                  '今天的心情是？',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
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
