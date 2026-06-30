import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/model/essay_entry.dart';
import '../../domain/model/mood_type.dart';
import '../../domain/repository/essay_repository.dart';
import '../database/app_database.dart' as db;

part 'essay_repository_impl.g.dart';

@riverpod
DiaryRepository diaryRepository(DiaryRepositoryRef ref) {
  return DiaryRepositoryImpl(ref.watch(db.appDatabaseProvider));
}

class DiaryRepositoryImpl implements DiaryRepository {
  final db.AppDatabase _db;

  DiaryRepositoryImpl(this._db);

  @override
  Future<List<DiaryEntry>> getAllEntries({int? limit, int? offset}) async {
    final query = _db.select(_db.diaryEntries)
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]);
    if (limit != null) query.limit(limit, offset: offset);
    final rows = await query.get();
    return rows.map(_toEntry).toList();
  }

  @override
  Future<DiaryEntry?> getEntryById(int id) async {
    final row = await (_db.select(_db.diaryEntries)
      ..where((t) => t.id.equals(id)))
        .getSingleOrNull();
    return row != null ? _toEntry(row) : null;
  }

  @override
  Future<List<DiaryEntry>> getEntriesByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final rows = await (_db.select(_db.diaryEntries)
      ..where((t) => t.createdAt.isBetween(
        Constant(start.millisecondsSinceEpoch),
        Constant(end.millisecondsSinceEpoch - 1),
      )))
        .get();
    return rows.map(_toEntry).toList();
  }

  @override
  Future<List<DiaryEntry>> getEntriesByDateRange(DateTime start, DateTime end) async {
    final rows = await (_db.select(_db.diaryEntries)
      ..where((t) => t.createdAt.isBetween(
        Constant(start.millisecondsSinceEpoch),
        Constant(end.millisecondsSinceEpoch - 1),
      )))
        .get();
    return rows.map(_toEntry).toList();
  }

  @override
  Future<List<DiaryEntry>> getEntriesByMood(MoodType mood) async {
    final rows = await (_db.select(_db.diaryEntries)
      ..where((t) => t.moodType.equals(mood.name)))
        .get();
    return rows.map(_toEntry).toList();
  }

  @override
  Future<List<DiaryEntry>> searchEntries(String query, {int? limit}) async {
    final pattern = '%$query%';
    final rows = await (_db.select(_db.diaryEntries)
      ..where((t) => t.content.like(pattern) | t.title.like(pattern)))
        .get();
    return rows.map(_toEntry).toList();
  }

  @override
  Future<int> insertEntry(DiaryEntry entry) async {
    return await _db.into(_db.diaryEntries).insert(db.DiaryEntriesCompanion(
      title: Value(entry.title),
      content: Value(entry.content),
      moodType: Value(entry.moodType.name),
      createdAt: Value(entry.createdAt.millisecondsSinceEpoch),
      updatedAt: Value(entry.updatedAt.millisecondsSinceEpoch),
      weatherTag: Value(entry.weatherTag),
      photoPaths: Value(entry.photoPaths.isNotEmpty ? jsonEncode(entry.photoPaths) : null),
      audioPath: Value(entry.audioPath),
      tags: Value(entry.tags.isNotEmpty ? jsonEncode(entry.tags) : null),
    ));
  }

  @override
  Future<void> updateEntry(DiaryEntry entry) async {
    await (_db.update(_db.diaryEntries)
      ..where((t) => t.id.equals(entry.id)))
        .write(db.DiaryEntriesCompanion(
      title: Value(entry.title),
      content: Value(entry.content),
      moodType: Value(entry.moodType.name),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      photoPaths: Value(entry.photoPaths.isNotEmpty ? jsonEncode(entry.photoPaths) : null),
      audioPath: Value(entry.audioPath),
      tags: Value(entry.tags.isNotEmpty ? jsonEncode(entry.tags) : null),
    ));
  }

  @override
  Future<void> deleteEntry(int id) async {
    await (_db.delete(_db.diaryEntries)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<int> getEntryCount() async {
    final row = await (_db.selectOnly(_db.diaryEntries)
      ..addColumns([_db.diaryEntries.id.count()])
    ).getSingle();
    return row.read(_db.diaryEntries.id.count()) ?? 0;
  }

  @override
  Future<int> getStreakCount() async {
    final rows = await (_db.selectOnly(_db.diaryEntries)
      ..addColumns([_db.diaryEntries.createdAt])
      ..orderBy([OrderingTerm(expression: _db.diaryEntries.createdAt, mode: OrderingMode.desc)])
    ).get();
    if (rows.isEmpty) return 0;
    final dates = rows
        .map((r) {
          final ms = r.read(_db.diaryEntries.createdAt);
          if (ms == null) return null;
          final d = DateTime.fromMillisecondsSinceEpoch(ms);
          return DateTime(d.year, d.month, d.day);
        })
        .nonNulls
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    int streak = 0;
    final today = DateTime.now();
    for (final date in dates) {
      final expected = today.subtract(Duration(days: streak));
      if (date.isAtSameMomentAs(DateTime(expected.year, expected.month, expected.day))) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  DiaryEntry _toEntry(db.DiaryEntry row) {
    return DiaryEntry(
      id: row.id,
      title: row.title,
      content: row.content,
      moodType: MoodType.values.firstWhere((m) => m.name == row.moodType),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(row.updatedAt),
      weatherTag: row.weatherTag,
      photoPaths: row.photoPaths != null
          ? List<String>.from(jsonDecode(row.photoPaths!))
          : [],
      audioPath: row.audioPath,
      tags: row.tags != null
          ? List<String>.from(jsonDecode(row.tags!))
          : [],
    );
  }
}
