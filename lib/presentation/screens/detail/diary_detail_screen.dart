import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/util/date_util.dart';
import '../../widgets/aurora_background.dart';
import '../../../domain/model/diary_entry.dart';
import '../../../domain/model/mood_type.dart';

class DiaryDetailScreen extends ConsumerWidget {
  final DiaryEntry entry;

  const DiaryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textWhite),
            onPressed: () => context.pop(),
          ),
          title: Text('日记详情', style: Theme.of(context).textTheme.headlineMedium),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: _moodColor(entry.moodType).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _moodColor(entry.moodType).withValues(alpha: 0.3)),
                        ),
                        child: Center(child: Text(entry.moodType.emoji, style: const TextStyle(fontSize: 22))),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${DateUtil.formatDate(entry.createdAt)} ${DateUtil.weekday(entry.createdAt)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(entry.moodType.label,
                            style: TextStyle(color: _moodColor(entry.moodType)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (entry.title != null && entry.title!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(entry.title!, style: Theme.of(context).textTheme.headlineLarge),
                ),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(entry.content, style: Theme.of(context).textTheme.bodyLarge),
                ),
              ),
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: entry.tags.map((tag) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.accentCyan.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.accentCyan.withValues(alpha: 0.2)),
                      ),
                      child: Text(tag, style: const TextStyle(fontSize: 12, color: AppColors.accentCyan)),
                    );
                  }).toList(),
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
