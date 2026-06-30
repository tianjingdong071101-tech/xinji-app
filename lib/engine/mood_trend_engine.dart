import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repository/essay_repository_impl.dart';
import '../domain/model/mood_type.dart';
import '../domain/repository/essay_repository.dart';

part 'mood_trend_engine.g.dart';

class TrendPoint {
  final DateTime date;
  final MoodType dominantMood;
  final double intensity;
  const TrendPoint({required this.date, required this.dominantMood, required this.intensity});
}

class MoodTrendEngine {
  final DiaryRepository _repo;
  MoodTrendEngine(this._repo);

  Future<List<TrendPoint>> getTrend(int days) async {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    final entries = await _repo.getEntriesByDateRange(start, now);

    final daily = <DateTime, List<MoodType>>{};
    for (final e in entries) {
      final day = DateTime(e.createdAt.year, e.createdAt.month, e.createdAt.day);
      daily.putIfAbsent(day, () => []).add(e.moodType);
    }

    final points = <TrendPoint>[];
    for (int i = days - 1; i >= 0; i--) {
      final date = now.subtract(Duration(days: i));
      final key = DateTime(date.year, date.month, date.day);
      final moods = daily[key];
      if (moods != null && moods.isNotEmpty) {
        final counts = <MoodType, int>{};
        for (final m in moods) {
          counts[m] = (counts[m] ?? 0) + 1;
        }
        final dominant = counts.entries.reduce((a, b) => a.value > b.value ? a : b).key;
        points.add(TrendPoint(
          date: key,
          dominantMood: dominant,
          intensity: counts[dominant]! / moods.length,
        ));
      }
    }
    return points;
  }
}

@riverpod
MoodTrendEngine moodTrendEngine(MoodTrendEngineRef ref) {
  return MoodTrendEngine(ref.watch(diaryRepositoryProvider));
}
