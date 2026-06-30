import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/util/date_util.dart';
import '../../../domain/model/essay_entry.dart';
import '../../../engine/scroll_sync_engine.dart';
import '../../providers/essay_providers.dart';
import '../../widgets/emotion_river.dart';
import '../insights/widgets/todo_bottom_sheet.dart';
import 'widgets/timeline_flow.dart';
import 'widgets/timeline_streak_bar.dart';

class TimelineScreen extends ConsumerStatefulWidget {
  const TimelineScreen({super.key});

  @override
  ConsumerState<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends ConsumerState<TimelineScreen> {
  final _scrollController = ScrollController();
  ScrollSyncEngine? _scrollEngine;

  @override
  void initState() {
    super.initState();
    _scrollEngine = ScrollSyncEngine(_scrollController);
  }

  @override
  void dispose() {
    _scrollEngine?.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(diaryListProvider);

    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Opacity(
            opacity: _scrollEngine?.headerOpacity ?? 1.0,
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16),
                        Text('心迹', style: Theme.of(context).textTheme.displayLarge),
                        SizedBox(height: 2),
                        Text(
                          '${DateUtil.formatDate(DateTime.now())} ${DateUtil.weekday(DateTime.now())}',
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.checklist, color: AppColors.accent),
                    onPressed: () => showModalBottomSheet(
                      context: context,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                      builder: (_) => TodoBottomSheet(date: DateTime.now()),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: AppColors.accent),
                    onPressed: () => context.push('/search'),
                  ),
                  entriesAsync.when(
                    data: (entries) => entries.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.auto_stories_outlined, color: AppColors.accent),
                            onPressed: () {
                              context.push('/story/${entries.first.id}', extra: {
                                'entry': entries.first,
                                'allEntries': entries,
                              });
                            },
                          )
                        : SizedBox.shrink(),
                    loading: () => SizedBox.shrink(),
                    error: (_, __) => SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: entriesAsync.when(
              data: (entries) {
                final today = DateTime.now();
                final todayMood = entries
                  .where((e) =>
                    e.createdAt.year == today.year &&
                    e.createdAt.month == today.month &&
                    e.createdAt.day == today.day)
                  .map((e) => e.moodType)
                  .firstOrNull;
                final recentMoods = entries
                  .where((e) => e.createdAt.isAfter(today.subtract(const Duration(days: 7))))
                  .map((e) => e.moodType)
                  .toList();
                return Column(
                  children: [
                    EmotionRiver(todayMood: todayMood, recentMoods: recentMoods),
                    TimelineStreakBar(streak: _calculateStreak(entries)),
                    Expanded(
                      child: TimelineFlow(
                        entries: entries,
                        onEntryTap: (entry) => context.push('/essay/${entry.id}', extra: entry),
                      ),
                    ),
                  ],
                );
              },
              loading: () => Column(
                children: [
                  EmotionRiver(todayMood: null),
                  Expanded(child: Center(child: CircularProgressIndicator(color: AppColors.accent))),
                ],
              ),
              error: (_, __) => Column(
                children: [
                  EmotionRiver(todayMood: null),
                  Expanded(child: Center(child: Text('加载失败'))),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateStreak(List<DiaryEntry> entries) {
    if (entries.isEmpty) return 0;
    final dates = entries
        .map((e) => DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    int streak = 0;
    final today = DateTime.now();
    for (final date in dates) {
      final expected = today.subtract(Duration(days: streak));
      if (date.isAtSameMomentAs(DateTime(expected.year, expected.month, expected.day))) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }
}
