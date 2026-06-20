import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/model/mood_type.dart';
import '../../widgets/aurora_background.dart';
import 'insights_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);

    return AuroraBackground(
      child: SafeArea(
        child: insightsAsync.when(
          data: (state) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('洞察', style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.neonCyan,
                )),
                const SizedBox(height: 24),
                Row(
                  children: [
                    _StatCard(label: '总日记', value: '${state.totalEntries}', color: AppColors.moodCalm),
                    const SizedBox(width: 12),
                    _StatCard(label: '连续天数', value: '${state.streakDays}', color: AppColors.moodHappy),
                    const SizedBox(width: 12),
                    _StatCard(label: '情绪种类', value: '${state.distribution.length}', color: AppColors.moodLonging),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('情绪分布（近30天）', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: state.distribution.isEmpty
                              ? Center(
                                  child: Text('暂无数据', style: Theme.of(context).textTheme.bodyMedium),
                                )
                              : PieChart(
                                  PieChartData(
                                    sections: state.distribution.entries.map((e) {
                                      return PieChartSectionData(
                                        value: e.value.toDouble(),
                                        title: '${e.key.label}\n${e.value}',
                                        color: _moodColor(e.key),
                                        titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                                        radius: 50,
                                      );
                                    }).toList(),
                                    centerSpaceRadius: 30,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: MoodType.values.map((mood) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10, height: 10,
                                  decoration: BoxDecoration(
                                    color: _moodColor(mood),
                                    shape: BoxShape.circle,
                                    boxShadow: [BoxShadow(color: _moodColor(mood).withValues(alpha: 0.5), blurRadius: 4)],
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text('${mood.emoji} ${mood.label}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator(color: AppColors.neonCyan)),
          error: (_, __) => const Center(child: Text('加载失败')),
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

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(value, style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w700, color: color,
              )),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
