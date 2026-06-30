import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/util/date_util.dart';
import '../../domain/model/mood_type.dart';
import '../screens/insights/widgets/star_background.dart';

class EmotionRiver extends StatefulWidget {
  final MoodType? todayMood;
  final List<MoodType> recentMoods;

  const EmotionRiver({
    super.key,
    this.todayMood,
    this.recentMoods = const [],
  });

  @override
  State<EmotionRiver> createState() => _EmotionRiverState();
}

class _EmotionRiverState extends State<EmotionRiver>
    with SingleTickerProviderStateMixin {
  late AnimationController _flowController;
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _flowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _flowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              _buildDateRow(context),
              const SizedBox(height: 12),
              _buildMainMood(context),
              if (widget.recentMoods.isNotEmpty) ...[
                const SizedBox(height: 14),
                _buildRecentFlow(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateRow(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${DateTime.now().day}',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    fontSize: 28,
                    height: 1,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
            ),
            Text(
              DateUtil.weekday(DateTime.now()),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    height: 1.1,
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
        const SizedBox(width: 14),
        SizedBox(
          height: 28,
          child: VerticalDivider(
            width: 1,
            thickness: 1,
            color: AppColors.borderLight,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  PulseDot(
                    color: widget.todayMood?.color ?? AppColors.textMuted,
                    size: 8,
                    glowing: widget.todayMood != null,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    widget.todayMood != null
                        ? '今日心情'
                        : '今天的心情是？',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textSecondary,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ],
              ),
              if (widget.recentMoods.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '过去 ${widget.recentMoods.length} 天',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.textMuted,
                      fontFamily: 'Epilogue',
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (widget.todayMood != null)
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, _) {
              final pulse = 1.0 + _pulseController.value * 0.08;
              return Transform.scale(
                scale: pulse,
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: widget.todayMood!.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.todayMood!.emoji,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  Widget _buildMainMood(BuildContext context) {
    if (widget.todayMood == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(Icons.edit_note, size: 16, color: AppColors.textMuted),
            const SizedBox(width: 8),
            Text(
              '记录今天的心情',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
                fontFamily: 'Epilogue',
              ),
            ),
          ],
        ),
      );
    }

    final mood = widget.todayMood!;
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulse = 1.0 + _pulseController.value * 0.04;
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
          decoration: BoxDecoration(
            color: mood.color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: mood.color.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Transform.scale(
                scale: pulse,
                child: Text(mood.emoji, style: const TextStyle(fontSize: 24)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mood.label,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: mood.color,
                        fontFamily: 'Fraunces',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _moodPhrase(mood),
                      style: TextStyle(
                        fontSize: 11,
                        color: mood.color.withValues(alpha: 0.7),
                        fontFamily: 'Epilogue',
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 4,
                height: 32,
                decoration: BoxDecoration(
                  color: mood.color,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRecentFlow(BuildContext context) {
    final moods = widget.recentMoods.take(7).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '情绪流',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
                fontFamily: 'Epilogue',
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(child: Container(height: 0.5, color: AppColors.borderLight)),
          ],
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 32,
          child: AnimatedBuilder(
            animation: _flowController,
            builder: (context, _) {
              return CustomPaint(
                size: const Size(double.infinity, 32),
                painter: _MoodFlowPainter(
                  moods: moods,
                  flowOffset: _flowController.value,
                  moodColors: moods.map((m) => m.color).toList(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: moods.asMap().entries.map((entry) {
            final idx = moods.length - 1 - entry.key;
            return Text(
              _dayLabel(idx),
              style: TextStyle(
                fontSize: 8,
                color: AppColors.textMuted.withValues(alpha: 0.6),
                fontFamily: 'Epilogue',
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  String _moodPhrase(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return '今天心情明亮';
      case MoodType.calm: return '内心平静安和';
      case MoodType.longing: return '思绪飘向远方';
      case MoodType.sad: return '有些淡淡的忧伤';
      case MoodType.anxious: return '心中有些不安';
      case MoodType.hopeful: return '满怀期待的一天';
    }
  }

  String _dayLabel(int daysAgo) {
    if (daysAgo == 0) return '今天';
    if (daysAgo == 1) return '昨天';
    return '${daysAgo}天前';
  }
}

class _MoodFlowPainter extends CustomPainter {
  final List<MoodType> moods;
  final double flowOffset;
  final List<Color> moodColors;

  _MoodFlowPainter({
    required this.moods,
    required this.flowOffset,
    required this.moodColors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final n = moods.length;
    if (n == 0) return;
    final spacing = size.width / (n + 1);
    final midY = size.height / 2;

    for (int i = 0; i < n; i++) {
      final x = spacing * (i + 1);
      final waveY = sin((i / n) * pi * 2 + flowOffset * pi * 2) * 6;
      final y = midY + waveY;

      final dotR = 4.0 - (n - 1 - i) * 0.35;
      final alpha = 0.5 + (i / n) * 0.5;

      final dotPaint = Paint()
        ..color = moodColors[i].withValues(alpha: alpha)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), dotR.clamp(2.0, 5.0), dotPaint);

      if (i < n - 1) {
        final nextX = spacing * (i + 2);
        final nextWaveY = sin(((i + 1) / n) * pi * 2 + flowOffset * pi * 2) * 6;
        final nextY = midY + nextWaveY;

        final linePaint = Paint()
          ..color = moodColors[i].withValues(alpha: 0.15)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;
        canvas.drawLine(Offset(x, y), Offset(nextX, nextY), linePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _MoodFlowPainter old) =>
      old.moods != moods || old.flowOffset != flowOffset;
}
