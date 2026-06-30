import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repository/essay_repository_impl.dart';
import '../domain/model/essay_entry.dart';
import '../domain/repository/essay_repository.dart';

part 'story_engine.g.dart';

class DiarySegment {
  final String label;
  final List<DiaryEntry> entries;

  const DiarySegment({required this.label, required this.entries});
}

class NarrativeData {
  final List<DiarySegment> segments;

  const NarrativeData({required this.segments});
}

class StoryEngine {
  final DiaryRepository _repo;

  StoryEngine(this._repo);

  Future<NarrativeData> getNarrative() async {
    final entries = await _repo.getAllEntries();
    if (entries.isEmpty) return const NarrativeData(segments: []);

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(today.year, today.month, 1);

    final Map<String, List<DiaryEntry>> groups = {};
    for (final entry in entries) {
      final d = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      String label;
      if (d.difference(today).inDays == 0) {
        label = '今天';
      } else if (d.difference(yesterday).inDays == 0) {
        label = '昨天';
      } else if (d.isAfter(weekStart.subtract(const Duration(days: 1)))) {
        label = '本周';
      } else if (d.isAfter(monthStart.subtract(const Duration(days: 1)))) {
        label = '本月';
      } else {
        label = '更早';
      }
      groups.putIfAbsent(label, () => []).add(entry);
    }

    final order = ['今天', '昨天', '本周', '本月', '更早'];
    final segments = order
        .where((l) => groups.containsKey(l))
        .map((l) => DiarySegment(label: l, entries: groups[l]!))
        .toList();

    return NarrativeData(segments: segments);
  }

  DiaryEntry? getPrevious(List<DiaryEntry> allEntries, int currentId) {
    final idx = allEntries.indexWhere((e) => e.id == currentId);
    if (idx <= 0) return null;
    return allEntries[idx - 1];
  }

  DiaryEntry? getNext(List<DiaryEntry> allEntries, int currentId) {
    final idx = allEntries.indexWhere((e) => e.id == currentId);
    if (idx < 0 || idx >= allEntries.length - 1) return null;
    return allEntries[idx + 1];
  }
}

@riverpod
StoryEngine storyEngine(StoryEngineRef ref) {
  return StoryEngine(ref.watch(diaryRepositoryProvider));
}
