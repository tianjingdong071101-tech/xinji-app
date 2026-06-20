import 'package:drift/drift.dart';

class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text().nullable()();
  TextColumn get content => text()();
  TextColumn get moodType => text()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  TextColumn get weatherTag => text().nullable()();
  TextColumn get photoPaths => text().nullable()();
  TextColumn get audioPath => text().nullable()();
  TextColumn get tags => text().nullable()();
}

class MoodRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get date => integer()();
  TextColumn get moodType => text()();
  IntColumn get entryId => integer().nullable()();
  IntColumn get createdAt => integer()();
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get color => text()();
  IntColumn get createdAt => integer()();
}
