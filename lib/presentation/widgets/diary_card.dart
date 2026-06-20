import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/util/date_util.dart';
import '../../domain/model/diary_entry.dart';
import '../../domain/model/mood_type.dart';

class DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;

  const DiaryCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final moodColor = _moodColor(entry.moodType);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.backgroundCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: moodColor.withValues(alpha: 0.15), width: 0.5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                        Container(
                          width: 10, height: 10,
                          decoration: BoxDecoration(
                            color: moodColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(color: moodColor.withValues(alpha: 0.5), blurRadius: 6),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            '${DateUtil.formatDay(entry.createdAt)} ${DateUtil.weekday(entry.createdAt)}',
                            style: Theme.of(context).textTheme.labelSmall,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${entry.moodType.emoji} ${entry.moodType.label}',
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(color: moodColor),
                        ),
                      ],
                    ),
                    if (entry.title != null && entry.title!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(entry.title!, style: Theme.of(context).textTheme.headlineMedium),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      entry.content,
                      style: Theme.of(context).textTheme.bodyMedium,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (entry.tags.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 4,
                        children: entry.tags.map((tag) => TagChip(label: tag, color: moodColor)).toList(),
                      ),
                    ],
                  ],
                ),
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

class TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const TagChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}
