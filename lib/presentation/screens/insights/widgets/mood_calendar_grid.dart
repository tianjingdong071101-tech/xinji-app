import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/model/mood_type.dart';

class MoodCalendarGrid extends StatefulWidget {
  final DateTime initialMonth;
  final void Function(DateTime)? onDayTap;
  final Map<DateTime, MoodType> dailyMoods;
  final Map<DateTime, int> todoCounts;

  const MoodCalendarGrid({
    super.key,
    required this.initialMonth,
    this.onDayTap,
    this.dailyMoods = const {},
    this.todoCounts = const {},
  });

  @override
  State<MoodCalendarGrid> createState() => _MoodCalendarGridState();
}

class _MoodCalendarGridState extends State<MoodCalendarGrid> {
  late DateTime _currentMonth;

  @override
  void initState() {
    super.initState();
    _currentMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month, 1);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthStart = _currentMonth;
    final monthEnd = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final firstWeekday = monthStart.weekday - 1;
    final daysInMonth = monthEnd.day;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: Icon(Icons.chevron_left, size: 20, color: AppColors.textPrimary),
              onPressed: _previousMonth,
            ),
            Text(
              '${_currentMonth.year}年${_currentMonth.month}月',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              icon: Icon(Icons.chevron_right, size: 20, color: AppColors.textPrimary),
              onPressed: _nextMonth,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: ['一', '二', '三', '四', '五', '六', '日']
              .map((d) => Expanded(child: Center(
                child: Text(d,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: d == '六' || d == '日'
                        ? AppColors.accent.withValues(alpha: 0.7)
                        : AppColors.textMuted,
                  ),
                ),
              )))
              .toList(),
        ),
        const SizedBox(height: 6),
        ...List.generate(_weeksCount(firstWeekday, daysInMonth), (w) {
          return Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Row(
              children: List.generate(7, (d) {
                final day = w * 7 + d - firstWeekday + 1;
                if (day < 1 || day > daysInMonth) {
                  return Expanded(child: const SizedBox(height: 40));
                }
                final date = DateTime(_currentMonth.year, _currentMonth.month, day);
                final mood = widget.dailyMoods[date];
                final isToday = _isToday(date);
                final isWeekend = d >= 5;
                final todoCount = widget.todoCounts[date] ?? 0;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onDayTap?.call(date),
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: mood != null
                            ? mood.color.withValues(alpha: 0.08)
                            : (isToday ? AppColors.accent.withValues(alpha: 0.06) : null),
                        borderRadius: BorderRadius.circular(12),
                        border: isToday
                            ? Border.all(color: AppColors.accent.withValues(alpha: 0.4), width: 1)
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$day',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                              color: isToday
                                  ? AppColors.accent
                                  : (isWeekend
                                      ? AppColors.textSecondary
                                      : AppColors.textPrimary),
                            ),
                          ),
                          if (mood != null && todoCount == 0)
                            Container(
                              width: 5,
                              height: 5,
                              margin: const EdgeInsets.only(top: 1),
                              decoration: BoxDecoration(
                                color: mood.color,
                                shape: BoxShape.circle,
                              ),
                            ),
                          if (todoCount > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              decoration: BoxDecoration(
                                color: AppColors.accent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '$todoCount',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          );
        }),
      ],
    );
  }

  int _weeksCount(int firstWeekday, int daysInMonth) {
    return ((firstWeekday + daysInMonth + 6) ~/ 7).clamp(4, 6);
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }
}
