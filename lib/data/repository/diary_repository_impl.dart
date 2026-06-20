import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/model/diary_entry.dart';
import '../../domain/model/mood_type.dart';
import '../../domain/repository/diary_repository.dart';
import '../database/app_database.dart' as db;
import '../database/tables.dart';

part 'diary_repository_impl.g.dart';

@riverpod
DiaryRepository diaryRepository(DiaryRepositoryRef ref) {
  return DiaryRepositoryImpl(ref.watch(db.appDatabaseProvider));
}

class DiaryRepositoryImpl implements DiaryRepository {
  final db.AppDatabase _db;

  DiaryRepositoryImpl(this._db);

  @override
  Future<List<DiaryEntry>> getAllEntries() async {
    final rows = await _db.select(_db.diaryEntries).get();
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
        Constant(end.millisecondsSinceEpoch),
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
  Future<List<DiaryEntry>> searchEntries(String query) async {
    final pattern = '%$query%';
    final rows = await (_db.select(_db.diaryEntries)
      ..where((t) => t.content.like(pattern) | (t.title?.like(pattern) ?? const Constant(false))))
        .get();
    return rows.map(_toEntry).toList();
  }

  @override
  Future<int> insertEntry(DiaryEntry entry) async {
    final uuid = const Uuid().v4().hashCode;
    final id = await _db.into(_db.diaryEntries).insert(db.DiaryEntriesCompanion(
      id: Value<int>(entry.id > 0 ? entry.id : uuid.abs()),
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
    return id;
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
    return (await _db.select(_db.diaryEntries).get()).length;
  }

  @override
  Future<int> getStreakCount() async {
    final entries = await _db.select(_db.diaryEntries).get();
    if (entries.isEmpty) return 0;
    final dates = entries
        .map((e) => DateTime.fromMillisecondsSinceEpoch(e.createdAt))
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));
    int streak = 0;
    final today = DateTime.now();
    for (int i = 0; i < dates.length; i++) {
      final expected = today.subtract(Duration(days: streak));
      if (dates[i].isAtSameMomentAs(expected)) {
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
