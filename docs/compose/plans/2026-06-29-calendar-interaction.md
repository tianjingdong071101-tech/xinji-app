# Calendar Interaction Enhancement Implementation Plan

> **For agentic workers:** Steps use checkbox (`- [ ]`) syntax. Implement task by task.

**Goal:** Add swipe-to-change-month, smooth animation, and "today" button to the mood calendar grid.

**Architecture:** Rewrite `MoodCalendarGrid` from static `Column` to `PageView`-based swipeable calendar. One `StatefulWidget` handles all interactions.

**Tech Stack:** Flutter, PageView, PageController, AnimatedSwitcher

---

### Task 1: Rewrite MoodCalendarGrid with PageView + swipe

**Files:**
- Modify: `lib/presentation/screens/insights/widgets/mood_calendar_grid.dart` (full rewrite)

- [ ] **Write the new MoodCalendarGrid**

Replace the current `Column`-based calendar with a `PageView` that contains one month per page. Use `PageController` for swipe and animated navigation. Add a "今天" button next to the month title.

```dart
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
  late PageController _pageController;
  late DateTime _baseMonth;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _baseMonth = DateTime(widget.initialMonth.year, widget.initialMonth.month, 1);
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  DateTime _monthForPage(int page) {
    return DateTime(_baseMonth.year, _baseMonth.month + page, 1);
  }

  void _goToMonth(DateTime month) {
    final target = (month.year - _baseMonth.year) * 12 + (month.month - _baseMonth.month);
    _pageController.animateToPage(target, duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  void _goToToday() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, 1);
    if (_baseMonth != today) setState(() => _baseMonth = today);
    _goToMonth(today);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header with navigation + today button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 20, color: AppColors.textPrimary),
                    onPressed: () => _goToMonth(_monthForPage(_currentPage - 1)),
                  ),
                  Text(
                    '${_monthForPage(_currentPage).year}年${_monthForPage(_currentPage).month}月',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_right, size: 20, color: AppColors.textPrimary),
                    onPressed: () => _goToMonth(_monthForPage(_currentPage + 1)),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _goToToday,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('今天', style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
        // Weekday headers
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: ['一', '二', '三', '四', '五', '六', '日']
                .map((d) => Expanded(child: Center(
                  child: Text(d, style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 11)),
                )))
                .toList(),
          ),
        ),
        SizedBox(height: 4),
        // Swipeable months
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (p) => setState(() => _currentPage = p),
            itemBuilder: (_, page) => _MonthGrid(
              month: _monthForPage(page),
              dailyMoods: widget.dailyMoods,
              todoCounts: widget.todoCounts,
              onDayTap: widget.onDayTap,
            ),
          ),
        ),
      ],
    );
  }
}

class _MonthGrid extends StatelessWidget {
  final DateTime month;
  final Map<DateTime, MoodType> dailyMoods;
  final Map<DateTime, int> todoCounts;
  final void Function(DateTime)? onDayTap;

  const _MonthGrid({
    required this.month,
    required this.dailyMoods,
    required this.todoCounts,
    this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstWeekday = month.weekday % 7;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: List.generate(_weeksCount(firstWeekday, daysInMonth), (w) {
          return Row(
            children: List.generate(7, (d) {
              final day = w * 7 + d - firstWeekday + 1;
              if (day < 1 || day > daysInMonth) {
                return Expanded(child: SizedBox(height: 44));
              }
              final date = DateTime(month.year, month.month, day);
              final mood = dailyMoods[date];
              final isToday = date.isAtSameMomentAs(today);
              return Expanded(
                child: GestureDetector(
                  onTap: () => onDayTap?.call(date),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      border: isToday ? Border.all(color: AppColors.accent, width: 1.5) : null,
                      borderRadius: isToday ? BorderRadius.circular(12) : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('$day', style: TextStyle(
                          fontSize: 14,
                          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                          color: AppColors.textPrimary,
                        )),
                        SizedBox(height: 2),
                        if (mood != null)
                          Container(width: 6, height: 6,
                            decoration: BoxDecoration(color: mood.color, shape: BoxShape.circle)),
                        if (todoCounts.containsKey(date) && todoCounts[date]! > 0)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text('${todoCounts[date]}',
                              style: TextStyle(fontSize: 9, color: AppColors.accent, fontWeight: FontWeight.w600)),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          );
        }),
      ),
    );
  }

  int _weeksCount(int firstWeekday, int daysInMonth) {
    return ((firstWeekday + daysInMonth + 6) ~/ 7).clamp(4, 6);
  }
}
```

- [ ] **Build and verify**

```bash
cd /data/data/com.termux/files/home && tar czf xinji-app.tar.gz --exclude='.git' --exclude='build' --exclude='.dart_tool' --exclude='*.log' xinji-app/ && scp -i ~/.ssh/Whiper.pem -o StrictHostKeyChecking=no xinji-app.tar.gz ubuntu@43.139.123.172:/home/ubuntu/ && rm xinji-app.tar.gz && ssh tisy "cd /home/ubuntu/xinji-app && export ANDROID_HOME=/home/ubuntu/android-sdk && export PATH=\$PATH:/home/ubuntu/flutter/bin && flutter pub get -q && dart run build_runner build --delete-conflicting-outputs -q && flutter build apk --release --split-per-abi 2>&1 | tail -5"
```
