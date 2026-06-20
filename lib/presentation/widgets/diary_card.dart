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
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
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
                      color: _moodColor(entry.moodType),
                      shape: BoxShape.circle,
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
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _moodColor(entry.moodType),
                    ),
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
              if (entry.photoPaths.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: entry.photoPaths.take(3).map((path) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(path, width: 48, height: 48, fit: BoxFit.cover),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: entry.tags.map((tag) => TagChip(label: tag)).toList(),
                ),
              ],
            ],
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
  const TagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentBrown.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(
        fontSize: 11, color: AppColors.accentBrown,
      )),
    );
  }
}
