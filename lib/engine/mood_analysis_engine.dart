import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repository/essay_repository_impl.dart';
import '../domain/model/mood_type.dart';
import '../domain/repository/essay_repository.dart';

part 'mood_analysis_engine.g.dart';

class MoodAnalysisEngine {
  final DiaryRepository _diaryRepo;
  MoodAnalysisEngine(this._diaryRepo);

  Future<Map<DateTime, MoodType?>> getDailyMoods(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final entries = await _diaryRepo.getEntriesByDateRange(start, end);
    final map = <DateTime, MoodType?>{};
    for (final entry in entries) {
      final day = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      map[day] = entry.moodType;
    }
    return map;
  }
}

@riverpod
MoodAnalysisEngine moodAnalysisEngine(MoodAnalysisEngineRef ref) {
  return MoodAnalysisEngine(ref.watch(diaryRepositoryProvider));
}
