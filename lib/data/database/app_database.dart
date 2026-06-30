import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [DiaryEntries, MoodRecords, Tags, Todos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    beforeOpen: (details) async {
      if (details.wasCreated) {
        await customStatement('PRAGMA journal_mode=WAL');
      }
    },
    onUpgrade: (details, from, to) async {
      if (from == 1) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS tags (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, color TEXT NOT NULL, created_at INTEGER NOT NULL)',
        );
        await customStatement(
          'CREATE TABLE IF NOT EXISTS mood_records (id INTEGER PRIMARY KEY AUTOINCREMENT, date INTEGER NOT NULL, mood_type TEXT NOT NULL, entry_id INTEGER, created_at INTEGER NOT NULL)',
        );
      }
      if (from == 2) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, completed INTEGER NOT NULL DEFAULT 0, priority TEXT NOT NULL DEFAULT \'normal\', date INTEGER NOT NULL, recurring TEXT NOT NULL DEFAULT \'none\', created_at INTEGER NOT NULL)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_todos_date ON todos(date)',
        );
      }
      if (from == 3) {
        await customStatement("ALTER TABLE todos ADD COLUMN recurring TEXT NOT NULL DEFAULT 'none'");
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(join(dir.path, 'xinji.db'));
    return NativeDatabase(file);
  });
}

@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}
