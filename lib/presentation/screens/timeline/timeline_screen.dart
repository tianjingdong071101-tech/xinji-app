import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/util/date_util.dart';
import '../../providers/diary_providers.dart';
import '../../widgets/diary_card.dart';
import '../../widgets/emotion_river.dart';
import '../../widgets/aurora_background.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(diaryListProvider);

    return AuroraBackground(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('心迹', style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: AppColors.textWhite,
                    shadows: [
                      Shadow(color: AppColors.accentCyan.withValues(alpha: 0.3), blurRadius: 20),
                    ],
                  )),
                  const SizedBox(height: 4),
                  Text(
                    '${DateUtil.formatDate(DateTime.now())} ${DateUtil.weekday(DateTime.now())}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: EmotionRiver(todayMood: null),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📝', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text('还没有日记', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Text(
                            '点击下方按钮，记录今天的心情',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textLabel.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: entries.length,
                    itemBuilder: (_, i) => DiaryCard(
                      entry: entries[i],
                      onTap: () => context.push('/diary/${entries[i].id}', extra: entries[i]),
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator(color: AppColors.accentCyan)),
                error: (_, __) => const Center(child: Text('加载失败')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
