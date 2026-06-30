import 'package:drift/drift.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/model/mood_type.dart';
import '../../domain/model/mood_record.dart';
import '../../domain/repository/mood_repository.dart';
import '../database/app_database.dart' as db;

part 'mood_repository_impl.g.dart';

@riverpod
MoodRepository moodRepository(MoodRepositoryRef ref) {
  return MoodRepositoryImpl(ref.watch(db.appDatabaseProvider));
}

class MoodRepositoryImpl implements MoodRepository {
  final db.AppDatabase _db;

  MoodRepositoryImpl(this._db);

  @override
  Future<List<MoodRecord>> getMoodRecords(DateTime start, DateTime end) async {
    final rows = await (_db.select(_db.moodRecords)
      ..where((t) => t.date.isBetween(
        Constant(start.millisecondsSinceEpoch),
        Constant(end.millisecondsSinceEpoch),
      )))
        .get();
    return rows.map((r) => MoodRecord(
      id: r.id,
      date: DateTime.fromMillisecondsSinceEpoch(r.date),
      moodType: MoodType.values.firstWhere((m) => m.name == r.moodType),
      entryId: r.entryId,
      createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
    )).toList();
  }

  @override
  Future<Map<MoodType, int>> getMoodDistribution(
    DateTime start, DateTime end,
  ) async {
    final rows = await (_db.selectOnly(_db.moodRecords)
      ..addColumns([_db.moodRecords.moodType, _db.moodRecords.id.count()])
      ..where(_db.moodRecords.date.isBetween(
        Constant(start.millisecondsSinceEpoch),
        Constant(end.millisecondsSinceEpoch),
      ))
      ..groupBy([_db.moodRecords.moodType])
    ).get();
    final map = <MoodType, int>{};
    for (final mood in MoodType.values) {
      map[mood] = 0;
    }
    for (final row in rows) {
      final mood = MoodType.values.firstWhere(
        (m) => m.name == row.read(_db.moodRecords.moodType),
      );
      map[mood] = row.read(_db.moodRecords.id.count()) ?? 0;
    }
    return map;
  }

  @override
  Future<int> insertRecord(MoodRecord record) async {
    return await _db.into(_db.moodRecords).insert(db.MoodRecordsCompanion(
      date: Value(record.date.millisecondsSinceEpoch),
      moodType: Value(record.moodType.name),
      entryId: Value(record.entryId),
      createdAt: Value(record.createdAt.millisecondsSinceEpoch),
    ));
  }
}
