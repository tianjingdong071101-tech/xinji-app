import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/model/mood_type.dart';
import '../../../domain/model/essay_entry.dart';
import '../../../engine/mood_analysis_engine.dart';
import '../../../engine/mood_trend_engine.dart';
import '../../../data/repository/essay_repository_impl.dart';
import '../../../data/repository/todo_repository_impl.dart';
import '../../widgets/mood_trend_chart.dart';
import '../../widgets/essay_card.dart';
import '../../widgets/emotion_river.dart';
import '../../providers/essay_providers.dart';
import 'insights_provider.dart';
import 'widgets/mood_calendar_grid.dart';
import 'widgets/mood_star_chart.dart';
import 'widgets/star_background.dart';

part 'insights_screen.g.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _selectedTab = 0;
  int _trendDays = 30;

  @override
  Widget build(BuildContext context) {
    final insightsAsync = ref.watch(insightsProvider);
    final dailyMoodsAsync = ref.watch(_dailyMoodsProvider);
    final entriesAsync = ref.watch(diaryListProvider);

    return SafeArea(
      child: entriesAsync.when(
        data: (entries) {
          final recentMoods = entries
              .where((e) =>
                  e.createdAt
                      .isAfter(DateTime.now().subtract(const Duration(days: 7))))
              .map((e) => e.moodType)
              .toList();
          final todayMood = entries
              .where((e) =>
                  e.createdAt.year == DateTime.now().year &&
                  e.createdAt.month == DateTime.now().month &&
                  e.createdAt.day == DateTime.now().day)
              .map((e) => e.moodType)
              .firstOrNull;

          return insightsAsync.when(
            data: (state) => SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('洞察',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(color: AppColors.accent)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${state.distribution.values.fold(0, (a, b) => a + b)} 条记录',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Epilogue',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  EmotionRiver(
                    todayMood: todayMood,
                    recentMoods: recentMoods,
                  ),
                  const SizedBox(height: 20),
                  _StatRow(
                    totalEntries: state.totalEntries,
                    streakDays: state.streakDays,
                    moodCount: state.distribution.length,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _TabButton(
                          label: '星图',
                          selected: _selectedTab == 0,
                          onTap: () =>
                              setState(() => _selectedTab = 0)),
                      const SizedBox(width: 8),
                      _TabButton(
                          label: '日历',
                          selected: _selectedTab == 1,
                          onTap: () =>
                              setState(() => _selectedTab = 1)),
                      const SizedBox(width: 8),
                      _TabButton(
                          label: '趋势',
                          selected: _selectedTab == 2,
                          onTap: () =>
                              setState(() => _selectedTab = 2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_selectedTab == 0) _buildStarTab(state),
                  if (_selectedTab == 1)
                    _buildCalendarTab(dailyMoodsAsync),
                  if (_selectedTab == 2) _buildTrendTab(),
                ],
              ),
            ),
            loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.accent)),
            error: (_, __) =>
                const Center(child: Text('加载失败')),
          );
        },
        loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.accent)),
        error: (_, __) => const Center(child: Text('加载失败')),
      ),
    );
  }

  Widget _buildStarTab(InsightsState state) {
    return StarBackground(
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
              color: AppColors.borderLight, width: 0.5),
        ),
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 4),
              child: Row(
                children: [
                  Text('情绪星图',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(fontSize: 20)),
                  const Spacer(),
                  Icon(Icons.auto_awesome,
                      size: 14,
                      color: AppColors.textMuted
                          .withValues(alpha: 0.5)),
                  const SizedBox(width: 4),
                  Text('点击查看详情',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.textMuted
                            .withValues(alpha: 0.5),
                        fontFamily: 'Epilogue',
                      )),
                ],
              ),
            ),
            MoodStarChart(distribution: state.distribution),
            const SizedBox(height: 8),
            _buildChartLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildChartLegend() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Wrap(
        spacing: 12,
        runSpacing: 6,
        children: MoodType.values.map((m) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: m.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                m.label,
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.textMuted,
                  fontFamily: 'Epilogue',
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCalendarTab(
      AsyncValue<Map<DateTime, MoodType?>> dailyMoodsAsync) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: dailyMoodsAsync.when(
        data: (moods) => FutureBuilder<Map<DateTime, int>>(
          future: ref
              .read(todoRepositoryProvider)
              .getUncompletedCountsByMonth(
                  DateTime.now().year, DateTime.now().month),
          builder: (_, snap) => MoodCalendarGrid(
            initialMonth: DateTime.now(),
            dailyMoods: moods.entries
                .where((e) => e.value != null)
                .fold<Map<DateTime, MoodType>>(
                    {}, (map, e) {
                  map[e.key] = e.value!;
                  return map;
                }),
            todoCounts: snap.data ?? const {},
            onDayTap: (date) async {
              final repo = ref.read(diaryRepositoryProvider);
              final entries = await repo.getEntriesByDate(date);
              if (!context.mounted) return;
              _showDayEntries(context, date, entries);
            },
          ),
        ),
        loading: () => const Center(
            child:
                CircularProgressIndicator(color: AppColors.accent)),
        error: (_, __) =>
            const Center(child: Text('加载失败')),
      ),
    );
  }

  Widget _buildTrendTab() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border:
            Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('情绪趋势',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge
                      ?.copyWith(fontSize: 20)),
              const Spacer(),
              ...[7, 30, 90].map((days) => Padding(
                    padding: const EdgeInsets.only(left: 4),
                    child: GestureDetector(
                      onTap: () =>
                          setState(() => _trendDays = days),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _trendDays == days
                              ? AppColors.accent
                              : Colors.transparent,
                          borderRadius:
                              BorderRadius.circular(12),
                          border: Border.all(
                            color: _trendDays == days
                                ? AppColors.accent
                                : AppColors.borderLight,
                          ),
                        ),
                        child: Text('${days}天',
                            style: TextStyle(
                              fontSize: 11,
                              color: _trendDays == days
                                  ? Colors.white
                                  : AppColors.textMuted,
                            )),
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 16),
          FutureBuilder<List<TrendPoint>>(
            future: ref
                .read(moodTrendEngineProvider)
                .getTrend(_trendDays),
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return SizedBox(
                    height: 200,
                    child: Center(
                        child: CircularProgressIndicator(
                            color: AppColors.accent)));
              }
              if (!snap.hasData || snap.data!.isEmpty) {
                return SizedBox(
                    height: 200,
                    child: Center(
                        child: Text('暂无数据',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium)));
              }
              return MoodTrendChart(
                  points: snap.data!, days: _trendDays);
            },
          ),
        ],
      ),
    );
  }

  void _showDayEntries(
      BuildContext context, DateTime date, List<DiaryEntry> entries) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Container(
        constraints: BoxConstraints(
            maxHeight:
                MediaQuery.of(context).size.height * 0.6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Row(
                children: [
                  Text('${date.month}月${date.day}日',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium),
                  const Spacer(),
                  if (entries.isEmpty)
                    Text('无随笔',
                        style: TextStyle(
                            color: AppColors.textMuted,
                            fontSize: 13)),
                ],
              ),
            ),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Text('这天没有随笔',
                    style:
                        TextStyle(color: AppColors.textMuted)),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: entries.length,
                  itemBuilder: (_, i) => EssayCard(
                    entry: entries[i],
                    onTap: () {
                      Navigator.of(context).pop();
                      context.push('/essay/${entries[i].id}',
                          extra: entries[i]);
                    },
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final int totalEntries;
  final int streakDays;
  final int moodCount;

  const _StatRow({
    required this.totalEntries,
    required this.streakDays,
    required this.moodCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        children: [
          _MiniStat(
            icon: Icons.article_outlined,
            value: '$totalEntries',
            label: '总随笔',
            color: AppColors.moodCalm,
          ),
          _StatDivider(),
          _MiniStat(
            icon: Icons.local_fire_department_outlined,
            value: '$streakDays',
            label: '连续天数',
            color: AppColors.moodHappy,
          ),
          _StatDivider(),
          _MiniStat(
            icon: Icons.auto_awesome,
            value: '$moodCount',
            label: '情绪种类',
            color: AppColors.moodLonging,
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const _MiniStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: color.withValues(alpha: 0.7)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: color,
              fontFamily: 'Fraunces',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: AppColors.textMuted,
              fontFamily: 'Epilogue',
            ),
          ),
        ],
      ),
    );
  }
}

class _StatDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: AppColors.borderLight.withValues(alpha: 0.5),
    );
  }
}

@riverpod
Future<Map<DateTime, MoodType?>> _dailyMoods(_DailyMoodsRef ref) async {
  final engine = ref.watch(moodAnalysisEngineProvider);
  final now = DateTime.now();
  return engine.getDailyMoods(now.year, now.month);
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 13,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? Colors.white : AppColors.textMuted,
        )),
      ),
    );
  }
}
