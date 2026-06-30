import 'package:flutter_test/flutter_test.dart';
import 'package:xinji_app/domain/model/essay_entry.dart';
import 'package:xinji_app/domain/model/mood_type.dart';
import 'package:xinji_app/domain/repository/essay_repository.dart';

class MockDiaryRepository implements DiaryRepository {
  final List<DiaryEntry> _entries = [];

  @override
  Future<List<DiaryEntry>> getAllEntries({int? limit, int? offset}) async {
    var list = _entries;
    if (offset != null) list = list.skip(offset).toList();
    if (limit != null) list = list.take(limit).toList();
    return list;
  }

  @override
  Future<DiaryEntry?> getEntryById(int id) async =>
      _entries.where((e) => e.id == id).firstOrNull;

  @override
  Future<List<DiaryEntry>> getEntriesByDate(DateTime date) async => _entries;

  @override
  Future<List<DiaryEntry>> getEntriesByDateRange(DateTime start, DateTime end) async => _entries;

  @override
  Future<List<DiaryEntry>> getEntriesByMood(MoodType mood) async =>
      _entries.where((e) => e.moodType == mood).toList();

  @override
  Future<List<DiaryEntry>> searchEntries(String query, {int? limit}) async =>
      _entries.where((e) => e.content.contains(query)).toList();

  @override
  Future<int> insertEntry(DiaryEntry entry) async {
    _entries.add(entry);
    return 1;
  }

  @override
  Future<void> updateEntry(DiaryEntry entry) async {}

  @override
  Future<void> deleteEntry(int id) async {
    _entries.removeWhere((e) => e.id == id);
  }

  @override
  Future<int> getEntryCount() async => _entries.length;

  @override
  Future<int> getStreakCount() async => 0;
}

void main() {
  group('DiaryRepository', () {
    test('should insert and retrieve entries', () async {
      final repo = MockDiaryRepository();
      final now = DateTime.now();

      await repo.insertEntry(DiaryEntry(
        id: 1,
        content: '测试随笔',
        moodType: MoodType.happy,
        createdAt: now,
        updatedAt: now,
      ));

      final entries = await repo.getAllEntries();
      expect(entries.length, 1);
      expect(entries.first.content, '测试随笔');
    });

    test('should search entries by content', () async {
      final repo = MockDiaryRepository();
      final now = DateTime.now();

      await repo.insertEntry(DiaryEntry(
        id: 1, content: '今天很开心', moodType: MoodType.happy,
        createdAt: now, updatedAt: now,
      ));
      await repo.insertEntry(DiaryEntry(
        id: 2, content: '有点忧伤', moodType: MoodType.sad,
        createdAt: now, updatedAt: now,
      ));

      final results = await repo.searchEntries('开心');
      expect(results.length, 1);
      expect(results.first.id, 1);
    });

    test('should delete entry', () async {
      final repo = MockDiaryRepository();
      final now = DateTime.now();

      await repo.insertEntry(DiaryEntry(
        id: 1, content: '测试', moodType: MoodType.calm,
        createdAt: now, updatedAt: now,
      ));
      await repo.deleteEntry(1);

      final entries = await repo.getAllEntries();
      expect(entries, isEmpty);
    });
  });
}
