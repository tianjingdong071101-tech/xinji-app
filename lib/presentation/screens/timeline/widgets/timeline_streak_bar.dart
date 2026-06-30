import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class TimelineStreakBar extends StatelessWidget {
  final int streak;

  const TimelineStreakBar({super.key, required this.streak});

  @override
  Widget build(BuildContext context) {
    if (streak <= 0) return SizedBox.shrink();
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_fire_department, size: 16, color: AppColors.accent),
          SizedBox(width: 6),
          Text('连续 ', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text('$streak', style: Theme.of(context).textTheme.displayLarge?.copyWith(
            fontSize: 18, color: AppColors.accent, fontWeight: FontWeight.w700,
          )),
          Text(' 天', style: TextStyle(fontSize: 13, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
