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

  @override
  Set<Index> get indexes => {
    Index('idx_diary_created_at', 'createdAt'),
    Index('idx_diary_mood_type', 'moodType'),
  };
}

class MoodRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get date => integer()();
  TextColumn get moodType => text()();
  IntColumn get entryId => integer().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Index> get indexes => {
    Index('idx_mood_date', 'date'),
    Index('idx_mood_type', 'moodType'),
  };
}

class Tags extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get color => text()();
  IntColumn get createdAt => integer()();
}

class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get completed => integer().withDefault(const Constant(0))();
  TextColumn get priority =>
      text().withDefault(const Constant('normal'))();
  IntColumn get date => integer()();
  TextColumn get recurring =>
      text().withDefault(const Constant('none'))();
  IntColumn get todoTime => integer().nullable()();
  IntColumn get createdAt => integer()();

  @override
  Set<Index> get indexes => {
    Index('idx_todos_date', 'date'),
  };
}
