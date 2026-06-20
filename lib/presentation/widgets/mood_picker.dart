import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/model/mood_type.dart';

class MoodPicker extends StatelessWidget {
  final MoodType? selectedMood;
  final ValueChanged<MoodType> onMoodSelected;

  const MoodPicker({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('此刻的心情', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: MoodType.values.map((mood) {
            final isSelected = mood == selectedMood;
            final moodColor = _moodColor(mood);
            return GestureDetector(
              onTap: () => onMoodSelected(mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                width: isSelected ? 58 : 46,
                height: isSelected ? 58 : 46,
                decoration: BoxDecoration(
                  color: isSelected ? moodColor.withValues(alpha: 0.12) : Colors.transparent,
                  borderRadius: BorderRadius.circular(isSelected ? 18 : 14),
                  border: isSelected
                      ? Border.all(color: moodColor.withValues(alpha: 0.5), width: 1.5)
                      : null,
                  boxShadow: isSelected
                      ? [BoxShadow(color: moodColor.withValues(alpha: 0.25), blurRadius: 14, spreadRadius: 2)]
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      mood.emoji,
                      style: TextStyle(fontSize: isSelected ? 26 : 20),
                    ),
                    if (isSelected)
                      Text(
                        mood.label,
                        style: TextStyle(
                          fontSize: 9,
                          color: moodColor,
                          shadows: [
                            Shadow(color: moodColor.withValues(alpha: 0.6), blurRadius: 8),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
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
