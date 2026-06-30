import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../engine/mood_trend_engine.dart';

class MoodTrendChart extends StatelessWidget {
  final List<TrendPoint> points;
  final int days;

  const MoodTrendChart({super.key, required this.points, required this.days});

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty) {
      return Center(child: Text('暂无数据', style: TextStyle(color: AppColors.textMuted)));
    }
    return SizedBox(
      height: 200,
      child: Padding(
        padding: EdgeInsets.only(right: 16, top: 8, bottom: 8),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (_) => FlLine(color: AppColors.borderLight, strokeWidth: 0.5),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 24,
                  interval: (days / 5).ceilToDouble().clamp(1, 30),
                  getTitlesWidget: (value, _) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= points.length) return SizedBox.shrink();
                    return Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        '${points[idx].date.month}/${points[idx].date.day}',
                        style: TextStyle(fontSize: 9, color: AppColors.textMuted),
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minY: -0.5,
            maxY: 5.5,
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(points.length, (i) {
                  return FlSpot(i.toDouble(), points[i].dominantMood.index.toDouble());
                }),
                isCurved: true,
                color: AppColors.accent,
                barWidth: 2,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, _, __, ___) {
                    final idx = spot.x.toInt();
                    if (idx < 0 || idx >= points.length) {
                      return FlDotCirclePainter(radius: 3, color: AppColors.accent, strokeWidth: 0);
                    }
                    return FlDotCirclePainter(
                      radius: 4,
                      color: points[idx].dominantMood.color,
                      strokeWidth: 2,
                      strokeColor: AppColors.card,
                    );
                  },
                ),
                belowBarData: BarAreaData(show: false),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
