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
            return GestureDetector(
              onTap: () => onMoodSelected(mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                width: isSelected ? 52 : 44,
                height: isSelected ? 52 : 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? _moodColor(mood).withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(isSelected ? 16 : 12),
                  border: isSelected
                      ? Border.all(color: _moodColor(mood), width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mood.emoji, style: TextStyle(fontSize: isSelected ? 28 : 22)),
                    if (isSelected)
                      Text(mood.label,
                        style: TextStyle(fontSize: 10, color: _moodColor(mood)),
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
