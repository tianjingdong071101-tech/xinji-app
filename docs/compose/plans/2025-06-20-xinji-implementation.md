# 「心迹」情感日记 App 实施计划

> [!NOTE]
> This document may not reflect the current implementation.
> See the final report for up-to-date state:
> [Final Report](../reports/xinji-app.md)

> **For agentic workers:** REQUIRED SUB-SKILL: Use compose:subagent or compose:execute to implement this plan task-by-task.

**Goal:** 构建「心迹」Flutter 情感日记 App 的完整 MVP

**Architecture:** Flutter + Clean Architecture（data/domain/presentation 三层），Drift SQLite 本地数据库，Riverpod 状态管理，go_router 路由

**Tech Stack:** Flutter, Dart, Drift, Riverpod, go_router, fl_chart, image_picker, record

---

## 文件结构

```
xinji-app/
├── pubspec.yaml
├── lib/
│   ├── main.dart
│   ├── app/
│   │   ├── app.dart
│   │   └── router.dart
│   ├── core/
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   └── app_theme.dart
│   │   └── util/
│   │       └── date_util.dart
│   ├── data/
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   └── tables.dart
│   │   └── repository/
│   │       ├── diary_repository_impl.dart
│   │       ├── mood_repository_impl.dart
│   │       └── tag_repository_impl.dart
│   ├── domain/
│   │   ├── model/
│   │   │   ├── diary_entry.dart
│   │   │   ├── mood_type.dart
│   │   │   └── tag.dart
│   │   └── repository/
│   │       ├── diary_repository.dart
│   │       ├── mood_repository.dart
│   │       └── tag_repository.dart
│   └── presentation/
│       ├── providers/
│       │   ├── diary_providers.dart
│       │   └── mood_providers.dart
│       ├── screens/
│       │   ├── timeline/
│       │   │   └── timeline_screen.dart
│       │   ├── write/
│       │   │   ├── write_screen.dart
│       │   │   └── write_provider.dart
│       │   ├── insights/
│       │   │   ├── insights_screen.dart
│       │   │   └── insights_provider.dart
│       │   ├── detail/
│       │   │   └── diary_detail_screen.dart
│       │   └── profile/
│       │       └── profile_screen.dart
│       └── widgets/
│           ├── mood_picker.dart
│           ├── emotion_river.dart
│           ├── diary_card.dart
│           └── tag_chip.dart
└── test/
    ├── data/
    │   └── repository/
    │       └── diary_repository_test.dart
    ├── domain/
    │   └── model/
    │       └── diary_entry_test.dart
    └── presentation/
        └── providers/
            └── diary_providers_test.dart
```

---

### Task 1: Flutter 项目脚手架

**Covers:** none (scaffold)

**Files:**
- Create: `xinji-app/pubspec.yaml`
- Create: `xinji-app/analysis_options.yaml`
- Create: `xinji-app/lib/main.dart`

- [ ] **Step 1: 创建 pubspec.yaml**

```yaml
name: xinji_app
description: 心迹 - 情感日记 App
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ^3.2.0

dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  go_router: ^14.2.0
  drift: ^2.19.0
  sqlite3_flutter_libs: ^0.5.0
  path_provider: ^2.1.3
  path: ^1.9.0
  fl_chart: ^0.68.0
  image_picker: ^1.0.7
  record: ^5.1.2
  intl: ^0.19.0
  uuid: ^4.4.0
  json_annotation: ^4.9.0
  equatable: ^2.0.5
  
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.2
  drift_dev: ^2.19.0
  riverpod_generator: ^2.4.0
  build_runner: ^2.4.9
  json_serializable: ^6.8.0
  mocktail: ^1.0.3

flutter:
  uses-material-design: true
```

- [ ] **Step 2: 创建 analysis_options.yaml**

```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    prefer_const_constructors: true
    prefer_const_declarations: true
    avoid_print: true
```

- [ ] **Step 3: 创建 main.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: XinjiApp()));
}
```

---

### Task 2: 主题系统

**Covers:** [S2]

**Files:**
- Create: `xinji-app/lib/core/theme/app_colors.dart`
- Create: `xinji-app/lib/core/theme/app_theme.dart`
- Create: `xinji-app/lib/core/util/date_util.dart`

- [ ] **Step 1: 创建 app_colors.dart**

```dart
import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Background
  static const Color sand = Color(0xFFE8DCC7);
  static const Color oat = Color(0xFFD4B895);
  static const Color cardWhite = Color(0xFFFFFFFF);

  // Text
  static const Color textPrimary = Color(0xFF2C2C2C);
  static const Color textSecondary = Color(0xFF8C8C8C);

  // Accent
  static const Color accentBrown = Color(0xFFC8956C);
  static const Color accentTerra = Color(0xFFC66B3D);

  // Mood colors
  static const Color moodHappy = Color(0xFFE8C170);
  static const Color moodCalm = Color(0xFFA0B8A0);
  static const Color moodLonging = Color(0xFF7BA7BC);
  static const Color moodSad = Color(0xFFB08BA0);
  static const Color moodAnxious = Color(0xFFC66B3D);
  static const Color moodHopeful = Color(0xFFA8C686);

  static Color moodColor(int index) {
    const colors = [
      moodHappy, moodCalm, moodLonging,
      moodSad, moodAnxious, moodHopeful,
    ];
    return colors[index % colors.length];
  }
}
```

- [ ] **Step 2: 创建 app_theme.dart**

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

class XinjiTheme {
  XinjiTheme._();

  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.sand,
      colorScheme: ColorScheme.light(
        primary: AppColors.accentBrown,
        onPrimary: AppColors.cardWhite,
        secondary: AppColors.accentTerra,
        surface: AppColors.cardWhite,
        onSurface: AppColors.textPrimary,
      ),
      cardTheme: CardThemeData(
        color: AppColors.cardWhite,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.accentBrown,
        foregroundColor: AppColors.cardWhite,
        shape: const CircleBorder(),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 20, fontWeight: FontWeight.normal, color: AppColors.textPrimary,
        ),
        headlineMedium: TextStyle(
          fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        bodyLarge: TextStyle(
          fontSize: 16, color: AppColors.textPrimary, height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14, color: AppColors.textSecondary, height: 1.4,
        ),
        labelLarge: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary,
        ),
        labelSmall: TextStyle(
          fontSize: 12, color: AppColors.textSecondary,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.cardWhite,
        selectedItemColor: AppColors.accentBrown,
        unselectedItemColor: AppColors.textSecondary,
      ),
    );
  }
}
```

- [ ] **Step 3: 创建 date_util.dart**

```dart
import 'package:intl/intl.dart';

class DateUtil {
  DateUtil._();

  static String formatDate(DateTime date) {
    return DateFormat('yyyy年MM月dd日', 'zh_CN').format(date);
  }

  static String formatDay(DateTime date) {
    return DateFormat('MM月dd日', 'zh_CN').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm', 'zh_CN').format(date);
  }

  static String formatMonth(DateTime date) {
    return DateFormat('yyyy年MM月', 'zh_CN').format(date);
  }

  static String weekday(DateTime date) {
    const weekdays = ['周一', '周二', '周三', '周四', '周五', '周六', '周日'];
    return weekdays[date.weekday - 1];
  }
}
```

---

### Task 3: 领域模型

**Covers:** [S4]

**Files:**
- Create: `xinji-app/lib/domain/model/mood_type.dart`
- Create: `xinji-app/lib/domain/model/tag.dart`
- Create: `xinji-app/lib/domain/model/diary_entry.dart`
- Create: `xinji-app/lib/domain/repository/diary_repository.dart`
- Create: `xinji-app/lib/domain/repository/mood_repository.dart`
- Create: `xinji-app/lib/domain/repository/tag_repository.dart`

- [ ] **Step 1: 创建 mood_type.dart**

```dart
enum MoodType {
  happy('快乐', '☀️'),
  calm('平静', '🌤'),
  longing('思念', '🌧'),
  sad('忧伤', '🌨'),
  anxious('焦虑', '🌪'),
  hopeful('期待', '🌈');

  final String label;
  final String emoji;

  const MoodType(this.label, this.emoji);
}
```

- [ ] **Step 2: 创建 tag.dart**

```dart
class Tag {
  final int id;
  final String name;
  final String color;
  final DateTime createdAt;

  const Tag({
    required this.id,
    required this.name,
    required this.color,
    required this.createdAt,
  });
}
```

- [ ] **Step 3: 创建 diary_entry.dart**

```dart
class DiaryEntry {
  final int id;
  final String? title;
  final String content;
  final MoodType moodType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? weatherTag;
  final List<String> photoPaths;
  final String? audioPath;
  final List<String> tags;

  const DiaryEntry({
    required this.id,
    this.title,
    required this.content,
    required this.moodType,
    required this.createdAt,
    required this.updatedAt,
    this.weatherTag,
    this.photoPaths = const [],
    this.audioPath,
    this.tags = const [],
  });
}
```

- [ ] **Step 4: 创建 diary_repository.dart**

```dart
import '../model/diary_entry.dart';
import '../model/mood_type.dart';

abstract class DiaryRepository {
  Future<List<DiaryEntry>> getAllEntries();
  Future<DiaryEntry?> getEntryById(int id);
  Future<List<DiaryEntry>> getEntriesByDate(DateTime date);
  Future<List<DiaryEntry>> getEntriesByMood(MoodType mood);
  Future<List<DiaryEntry>> searchEntries(String query);
  Future<int> insertEntry(DiaryEntry entry);
  Future<void> updateEntry(DiaryEntry entry);
  Future<void> deleteEntry(int id);
  Future<int> getEntryCount();
  Future<int> getStreakCount();
}
```

- [ ] **Step 5: 创建 mood_repository.dart**

```dart
import '../model/mood_type.dart';

class MoodRecord {
  final int id;
  final DateTime date;
  final MoodType moodType;
  final int? entryId;
  final DateTime createdAt;

  const MoodRecord({
    required this.id,
    required this.date,
    required this.moodType,
    this.entryId,
    required this.createdAt,
  });
}

abstract class MoodRepository {
  Future<List<MoodRecord>> getMoodRecords(DateTime start, DateTime end);
  Future<Map<MoodType, int>> getMoodDistribution(
    DateTime start, DateTime end,
  );
  Future<int> insertRecord(MoodRecord record);
}
```

- [ ] **Step 6: 创建 tag_repository.dart**

```dart
import '../model/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getAllTags();
  Future<Tag?> getTagByName(String name);
  Future<int> insertTag(Tag tag);
  Future<void> deleteTag(int id);
}
```

---

### Task 4: 数据库层 (Drift)

**Covers:** [S3, S4]

**Files:**
- Create: `xinji-app/lib/data/database/tables.dart`
- Create: `xinji-app/lib/data/database/app_database.dart`

- [ ] **Step 1: 创建 tables.dart**

```dart
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
```

- [ ] **Step 2: 创建 app_database.dart**

```dart
import 'dart:async';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [DiaryEntries, MoodRecords, Tags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(join(dir.path, 'xinji.db'));
    return NativeDatabase(file);
  });
}
```

---

### Task 5: Repository 实现

**Covers:** [S3, S4]

**Files:**
- Create: `xinji-app/lib/data/repository/diary_repository_impl.dart`
- Create: `xinji-app/lib/data/repository/mood_repository_impl.dart`
- Create: `xinji-app/lib/data/repository/tag_repository_impl.dart`

- [ ] **Step 1: 创建 diary_repository_impl.dart**

```dart
import 'dart:convert';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/model/diary_entry.dart';
import '../../domain/model/mood_type.dart';
import '../../domain/repository/diary_repository.dart';
import '../database/app_database.dart';
import '../database/tables.dart';

part 'diary_repository_impl.g.dart';

@riverpod
DiaryRepository diaryRepository(DiaryRepositoryRef ref) {
  return DiaryRepositoryImpl(ref.watch(appDatabaseProvider));
}

class DiaryRepositoryImpl implements DiaryRepository {
  final AppDatabase _db;

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
      ..where((t) => t.createdAt.isBetweenValues(
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
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
    final rows = await (_db.select(_db.diaryEntries)
      ..where((t) => t.content.contains(query) | (t.title?.contains(query) ?? const Constant(false))))
        .get();
    return rows.map(_toEntry).toList();
  }

  @override
  Future<int> insertEntry(DiaryEntry entry) async {
    final uuid = const Uuid().v4().hashCode;
    final id = await _db.into(_db.diaryEntries).insert(DiaryEntriesCompanion(
      id: Value(entry.id > 0 ? entry.id : uuid.abs()),
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
        .write(DiaryEntriesCompanion(
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
    await (_db.delete(_db.diaryEntries)
      ..where((t) => t.id.equals(id)))
        .go();
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

  DiaryEntry _toEntry(DiaryEntryData row) {
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
```

- [ ] **Step 2: 创建 mood_repository_impl.dart**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/model/mood_type.dart';
import '../../domain/repository/mood_repository.dart';
import '../database/app_database.dart';
import '../database/tables.dart';

part 'mood_repository_impl.g.dart';

@riverpod
MoodRepository moodRepository(MoodRepositoryRef ref) {
  return MoodRepositoryImpl(ref.watch(appDatabaseProvider));
}

class MoodRepositoryImpl implements MoodRepository {
  final AppDatabase _db;

  MoodRepositoryImpl(this._db);

  @override
  Future<List<MoodRecord>> getMoodRecords(DateTime start, DateTime end) async {
    final rows = await (_db.select(_db.moodRecords)
      ..where((t) => t.date.isBetweenValues(
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
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
    final rows = await (_db.select(_db.moodRecords)
      ..where((t) => t.date.isBetweenValues(
        start.millisecondsSinceEpoch,
        end.millisecondsSinceEpoch,
      )))
        .get();
    final map = <MoodType, int>{};
    for (final mood in MoodType.values) {
      map[mood] = 0;
    }
    for (final row in rows) {
      final mood = MoodType.values.firstWhere((m) => m.name == row.moodType);
      map[mood] = (map[mood] ?? 0) + 1;
    }
    return map;
  }

  @override
  Future<int> insertRecord(MoodRecord record) async {
    return await _db.into(_db.moodRecords).insert(MoodRecordsCompanion(
      date: Value(record.date.millisecondsSinceEpoch),
      moodType: Value(record.moodType.name),
      entryId: Value(record.entryId),
      createdAt: Value(record.createdAt.millisecondsSinceEpoch),
    ));
  }
}
```

- [ ] **Step 3: 创建 tag_repository_impl.dart**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/model/tag.dart';
import '../../domain/repository/tag_repository.dart';
import '../database/app_database.dart';
import '../database/tables.dart';

part 'tag_repository_impl.g.dart';

@riverpod
TagRepository tagRepository(TagRepositoryRef ref) {
  return TagRepositoryImpl(ref.watch(appDatabaseProvider));
}

class TagRepositoryImpl implements TagRepository {
  final AppDatabase _db;

  TagRepositoryImpl(this._db);

  @override
  Future<List<Tag>> getAllTags() async {
    final rows = await _db.select(_db.tags).get();
    return rows.map((r) => Tag(
      id: r.id,
      name: r.name,
      color: r.color,
      createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
    )).toList();
  }

  @override
  Future<Tag?> getTagByName(String name) async {
    final row = await (_db.select(_db.tags)
      ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    return row != null ? Tag(
      id: row.id, name: row.name,
      color: row.color,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    ) : null;
  }

  @override
  Future<int> insertTag(Tag tag) async {
    return await _db.into(_db.tags).insert(TagsCompanion(
      name: Value(tag.name),
      color: Value(tag.color),
      createdAt: Value(tag.createdAt.millisecondsSinceEpoch),
    ));
  }

  @override
  Future<void> deleteTag(int id) async {
    await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
  }
}
```

- [ ] **Step 4: 创建 app_database provider**

```dart
// Add to app_database.dart or create app_database.dart with this
@riverpod
AppDatabase appDatabase(AppDatabaseRef ref) {
  return AppDatabase();
}
```

---

### Task 6: 核心 UI 组件

**Covers:** [S5]

**Files:**
- Create: `xinji-app/lib/presentation/widgets/mood_picker.dart`
- Create: `xinji-app/lib/presentation/widgets/diary_card.dart`
- Create: `xinji-app/lib/presentation/widgets/emotion_river.dart`
- Create: `xinji-app/lib/presentation/widgets/tag_chip.dart`

- [ ] **Step 1: 创建 mood_picker.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/model/mood_type.dart';

class MoodPicker extends StatelessWidget {
  final MoodType? selectedMood;
  final ValueChanged<MoodType> onMoodSelected;

  const MoodPicker({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('此刻的心情', style: Theme.of(context).textTheme.labelSmall),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: MoodType.values.map((mood) {
            final isSelected = mood == selectedMood;
            return GestureDetector(
              onTap: () => onMoodSelected(mood),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.elasticOut,
                width: isSelected ? 60 : 50,
                height: isSelected ? 60 : 50,
                decoration: BoxDecoration(
                  color: isSelected
                      ? _moodColor(mood).withValues(alpha: 0.2)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(isSelected ? 16 : 12),
                  border: isSelected
                      ? Border.all(color: _moodColor(mood), width: 2)
                      : null,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(mood.emoji, style: TextStyle(fontSize: isSelected ? 28 : 22)),
                    if (isSelected)
                      Text(mood.label,
                        style: TextStyle(fontSize: 10, color: _moodColor(mood)),
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _moodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return AppColors.moodHappy;
      case MoodType.calm: return AppColors.moodCalm;
      case MoodType.longing: return AppColors.moodLonging;
      case MoodType.sad: return AppColors.moodSad;
      case MoodType.anxious: return AppColors.moodAnxious;
      case MoodType.hopeful: return AppColors.moodHopeful;
    }
  }
}
```

- [ ] **Step 2: 创建 diary_card.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/util/date_util.dart';
import '../../domain/model/diary_entry.dart';
import '../../domain/model/mood_type.dart';

class DiaryCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback onTap;

  const DiaryCard({super.key, required this.entry, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10, height: 10,
                    decoration: BoxDecoration(
                      color: _moodColor(entry.moodType),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${DateUtil.formatDay(entry.createdAt)} ${DateUtil.weekday(entry.createdAt)}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                  const Spacer(),
                  Text(
                    '${entry.moodType.emoji} ${entry.moodType.label}',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: _moodColor(entry.moodType),
                    ),
                  ),
                ],
              ),
              if (entry.title != null && entry.title!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(entry.title!, style: Theme.of(context).textTheme.headlineMedium),
              ],
              const SizedBox(height: 4),
              Text(
                entry.content,
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (entry.photoPaths.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: entry.photoPaths.take(3).map((path) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(path, width: 48, height: 48, fit: BoxFit.cover),
                      ),
                    );
                  }).toList(),
                ),
              ],
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: entry.tags.map((tag) => TagChip(label: tag)).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _moodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return AppColors.moodHappy;
      case MoodType.calm: return AppColors.moodCalm;
      case MoodType.longing: return AppColors.moodLonging;
      case MoodType.sad: return AppColors.moodSad;
      case MoodType.anxious: return AppColors.moodAnxious;
      case MoodType.hopeful: return AppColors.moodHopeful;
    }
  }
}

class TagChip extends StatelessWidget {
  final String label;
  const TagChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.accentBrown.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label, style: const TextStyle(
        fontSize: 11, color: AppColors.accentBrown,
      )),
    );
  }
}
```

- [ ] **Step 3: 创建 emotion_river.dart**

```dart
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/model/mood_type.dart';

class EmotionRiver extends StatelessWidget {
  final MoodType? todayMood;
  final List<MoodType> recentMoods;

  const EmotionRiver({
    super.key,
    this.todayMood,
    this.recentMoods = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: recentMoods.isEmpty
              ? [AppColors.oat, AppColors.sand]
              : recentMoods.map(_moodColor).toList(),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Center(
        child: todayMood != null
            ? Text(todayMood!.emoji, style: const TextStyle(fontSize: 36))
            : Text(
                '今天的心情是？',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
      ),
    );
  }

  Color _moodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return AppColors.moodHappy;
      case MoodType.calm: return AppColors.moodCalm;
      case MoodType.longing: return AppColors.moodLonging;
      case MoodType.sad: return AppColors.moodSad;
      case MoodType.anxious: return AppColors.moodAnxious;
      case MoodType.hopeful: return AppColors.moodHopeful;
    }
  }
}
```

---

### Task 7: 情绪时间线页面

**Covers:** [S5]

**Files:**
- Create: `xinji-app/lib/presentation/providers/diary_providers.dart`
- Create: `xinji-app/lib/presentation/screens/timeline/timeline_screen.dart`

- [ ] **Step 1: 创建 diary_providers.dart**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repository/diary_repository_impl.dart';
import '../../domain/model/diary_entry.dart';

part 'diary_providers.g.dart';

@riverpod
class DiaryList extends _$DiaryList {
  @override
  Future<List<DiaryEntry>> build() async {
    final repo = ref.watch(diaryRepositoryProvider);
    return repo.getAllEntries();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class DiarySearch extends _$DiarySearch {
  @override
  Future<List<DiaryEntry>> build(String query) async {
    if (query.isEmpty) return [];
    final repo = ref.watch(diaryRepositoryProvider);
    return repo.searchEntries(query);
  }
}
```

- [ ] **Step 2: 创建 timeline_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/util/date_util.dart';
import '../../domain/model/diary_entry.dart';
import '../../providers/diary_providers.dart';
import '../../widgets/diary_card.dart';
import '../../widgets/emotion_river.dart';

class TimelineScreen extends ConsumerWidget {
  const TimelineScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(diaryListProvider);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text('心迹', style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    color: AppColors.accentBrown,
                  )),
                  const SizedBox(height: 4),
                  Text(
                    '${DateUtil.formatDate(DateTime.now())} ${DateUtil.weekday(DateTime.now())}',
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: EmotionRiver(todayMood: null),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: entriesAsync.when(
                data: (entries) {
                  if (entries.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('📝', style: TextStyle(fontSize: 48)),
                          const SizedBox(height: 16),
                          Text('还没有日记', style: Theme.of(context).textTheme.bodyMedium),
                          const SizedBox(height: 8),
                          Text(
                            '点击下方按钮，记录今天的心情',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: entries.length,
                    itemBuilder: (_, i) => DiaryCard(
                      entry: entries[i],
                      onTap: () {},
                    ),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, __) => const Center(child: Text('加载失败')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### Task 8: 写日记页面

**Covers:** [S5]

**Files:**
- Create: `xinji-app/lib/presentation/screens/write/write_provider.dart`
- Create: `xinji-app/lib/presentation/screens/write/write_screen.dart`

- [ ] **Step 1: 创建 write_provider.dart**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repository/diary_repository_impl.dart';
import '../../../domain/model/mood_type.dart';

class WriteDiaryState {
  final String title;
  final String content;
  final MoodType? mood;
  final List<String> tags;
  final List<String> photoPaths;
  final bool isSaving;
  final bool saved;

  const WriteDiaryState({
    this.title = '',
    this.content = '',
    this.mood,
    this.tags = const [],
    this.photoPaths = const [],
    this.isSaving = false,
    this.saved = false,
  });

  WriteDiaryState copyWith({
    String? title,
    String? content,
    MoodType? mood,
    List<String>? tags,
    List<String>? photoPaths,
    bool? isSaving,
    bool? saved,
    bool clearMood = false,
  }) {
    return WriteDiaryState(
      title: title ?? this.title,
      content: content ?? this.content,
      mood: clearMood ? null : (mood ?? this.mood),
      tags: tags ?? this.tags,
      photoPaths: photoPaths ?? this.photoPaths,
      isSaving: isSaving ?? this.isSaving,
      saved: saved ?? this.saved,
    );
  }
}

class WriteDiaryNotifier extends StateNotifier<WriteDiaryState> {
  WriteDiaryNotifier() : super(const WriteDiaryState());

  void updateTitle(String title) => state = state.copyWith(title: title);
  void updateContent(String content) => state = state.copyWith(content: content);
  void selectMood(MoodType mood) => state = state.copyWith(mood: mood);
  void addTag(String tag) => state = state.copyWith(tags: [...state.tags, tag]);
  void removeTag(String tag) => state = state.copyWith(
    tags: state.tags.where((t) => t != tag).toList(),
  );
  void addPhoto(String path) => state = state.copyWith(
    photoPaths: [...state.photoPaths, path],
  );
  void removePhoto(String path) => state = state.copyWith(
    photoPaths: state.photoPaths.where((p) => p != path).toList(),
  );
  void reset() => state = const WriteDiaryState();
}
```

- [ ] **Step 2: 创建 write_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/model/mood_type.dart';
import '../../widgets/mood_picker.dart';
import 'write_provider.dart';

final writeDiaryProvider = StateNotifierProvider<WriteDiaryNotifier, WriteDiaryState>((ref) {
  return WriteDiaryNotifier();
});

class WriteScreen extends ConsumerWidget {
  const WriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writeDiaryProvider);

    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('写日记', style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          TextButton(
            onPressed: state.mood == null || state.content.isEmpty
                ? null
                : () {
                    ref.read(writeDiaryProvider.notifier).reset();
                    Navigator.of(context).pop();
                  },
            child: Text('保存', style: TextStyle(
              color: state.mood == null || state.content.isEmpty
                  ? AppColors.textSecondary
                  : AppColors.accentBrown,
            )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mood picker
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: MoodPicker(
                  selectedMood: state.mood,
                  onMoodSelected: (mood) => ref.read(writeDiaryProvider.notifier).selectMood(mood),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            TextField(
              onChanged: (v) => ref.read(writeDiaryProvider.notifier).updateTitle(v),
              decoration: InputDecoration(
                hintText: '给今天的日记起个标题（可选）',
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
                border: InputBorder.none,
              ),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 16),
            // Content
            Card(
              child: TextField(
                onChanged: (v) => ref.read(writeDiaryProvider.notifier).updateContent(v),
                maxLines: null,
                minLines: 10,
                decoration: InputDecoration(
                  hintText: '今天发生了什么？你的感受是？',
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 16),
            // Tags
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('标签', style: Theme.of(context).textTheme.labelSmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ...state.tags.map((tag) => Chip(
                          label: Text(tag, style: const TextStyle(fontSize: 12)),
                          onDeleted: () => ref.read(writeDiaryProvider.notifier).removeTag(tag),
                          deleteIconColor: AppColors.accentBrown,
                          backgroundColor: AppColors.accentBrown.withValues(alpha: 0.1),
                        )),
                        ActionChip(
                          label: const Text('+ 添加', style: TextStyle(fontSize: 12)),
                          onPressed: () => _showTagDialog(context, ref),
                          backgroundColor: AppColors.accentBrown.withValues(alpha: 0.05),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTagDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('添加标签'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '输入标签名'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(writeDiaryProvider.notifier).addTag(controller.text);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('添加'),
          ),
        ],
      ),
    );
  }
}
```

---

### Task 9: 洞察页面

**Covers:** [S5]

**Files:**
- Create: `xinji-app/lib/presentation/screens/insights/insights_provider.dart`
- Create: `xinji-app/lib/presentation/screens/insights/insights_screen.dart`

- [ ] **Step 1: 创建 insights_provider.dart**

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../data/repository/mood_repository_impl.dart';
import '../../../domain/model/mood_type.dart';
import '../../../domain/repository/mood_repository.dart';

part 'insights_provider.g.dart';

class InsightsState {
  final Map<MoodType, int> distribution;
  final int totalEntries;
  final int streakDays;

  const InsightsState({
    this.distribution = const {},
    this.totalEntries = 0,
    this.streakDays = 0,
  });
}

@riverpod
class Insights extends _$Insights {
  @override
  Future<InsightsState> build() async {
    final moodRepo = ref.watch(moodRepositoryProvider);
    final diaryRepo = ref.watch(diaryRepositoryProvider);

    final now = DateTime.now();
    final monthAgo = now.subtract(const Duration(days: 30));
    final distribution = await moodRepo.getMoodDistribution(monthAgo, now);
    final total = await diaryRepo.getEntryCount();
    final streak = await diaryRepo.getStreakCount();

    return InsightsState(
      distribution: distribution,
      totalEntries: total,
      streakDays: streak,
    );
  }
}
```

- [ ] **Step 2: 创建 insights_screen.dart**

```dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/model/mood_type.dart';
import 'insights_provider.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final insightsAsync = ref.watch(insightsProvider);

    return Scaffold(
      body: SafeArea(
        child: insightsAsync.when(
          data: (state) => SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Text('洞察', style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.accentBrown,
                )),
                const SizedBox(height: 24),
                // Stats cards
                Row(
                  children: [
                    _StatCard(label: '总日记', value: '${state.totalEntries}', color: AppColors.moodCalm),
                    const SizedBox(width: 12),
                    _StatCard(label: '连续天数', value: '${state.streakDays}', color: AppColors.moodHappy),
                    const SizedBox(width: 12),
                    _StatCard(label: '情绪种类', value: '${state.distribution.length}', color: AppColors.moodLonging),
                  ],
                ),
                const SizedBox(height: 24),
                // Mood distribution chart
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('情绪分布（近30天）', style: Theme.of(context).textTheme.headlineMedium),
                        const SizedBox(height: 16),
                        SizedBox(
                          height: 200,
                          child: state.distribution.isEmpty
                              ? Center(
                                  child: Text('暂无数据', style: Theme.of(context).textTheme.bodyMedium),
                                )
                              : PieChart(
                                  PieChartData(
                                    sections: state.distribution.entries.map((e) {
                                      return PieChartSectionData(
                                        value: e.value.toDouble(),
                                        title: '${e.key.label}\n${e.value}',
                                        color: _moodColor(e.key),
                                        titleStyle: const TextStyle(fontSize: 10, color: Colors.white),
                                        radius: 50,
                                      );
                                    }).toList(),
                                    centerSpaceRadius: 30,
                                  ),
                                ),
                        ),
                        const SizedBox(height: 16),
                        // Legend
                        Wrap(
                          spacing: 16,
                          runSpacing: 8,
                          children: MoodType.values.map((mood) {
                            return Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 10, height: 10,
                                  decoration: BoxDecoration(
                                    color: _moodColor(mood),
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text('${mood.emoji} ${mood.label}',
                                  style: Theme.of(context).textTheme.labelSmall,
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (_, __) => const Center(child: Text('加载失败')),
        ),
      ),
    );
  }

  Color _moodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return AppColors.moodHappy;
      case MoodType.calm: return AppColors.moodCalm;
      case MoodType.longing: return AppColors.moodLonging;
      case MoodType.sad: return AppColors.moodSad;
      case MoodType.anxious: return AppColors.moodAnxious;
      case MoodType.hopeful: return AppColors.moodHopeful;
    }
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Text(value, style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.w600, color: color,
              )),
              const SizedBox(height: 4),
              Text(label, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ),
    );
  }
}
```

---

### Task 10: 日记详情页

**Covers:** [S5]

**Files:**
- Create: `xinji-app/lib/presentation/screens/detail/diary_detail_screen.dart`

- [ ] **Step 1: 创建 diary_detail_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/util/date_util.dart';
import '../../../domain/model/diary_entry.dart';
import '../../../domain/model/mood_type.dart';

class DiaryDetailScreen extends ConsumerWidget {
  final DiaryEntry entry;

  const DiaryDetailScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.sand,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('日记详情', style: Theme.of(context).textTheme.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and mood
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        color: _moodColor(entry.moodType).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(child: Text(entry.moodType.emoji, style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${DateUtil.formatDate(entry.createdAt)} ${DateUtil.weekday(entry.createdAt)}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        Text(entry.moodType.label,
                          style: TextStyle(color: _moodColor(entry.moodType)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Title
            if (entry.title != null && entry.title!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(entry.title!, style: Theme.of(context).textTheme.headlineLarge),
              ),
            // Content
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(entry.content, style: Theme.of(context).textTheme.bodyLarge),
              ),
            ),
            // Tags
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                children: entry.tags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.accentBrown.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(tag, style: const TextStyle(
                      fontSize: 12, color: AppColors.accentBrown,
                    )),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _moodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return AppColors.moodHappy;
      case MoodType.calm: return AppColors.moodCalm;
      case MoodType.longing: return AppColors.moodLonging;
      case MoodType.sad: return AppColors.moodSad;
      case MoodType.anxious: return AppColors.moodAnxious;
      case MoodType.hopeful: return AppColors.moodHopeful;
    }
  }
}
```

---

### Task 11: 个人设置页面

**Covers:** [S5]

**Files:**
- Create: `xinji-app/lib/presentation/screens/profile/profile_screen.dart`

- [ ] **Step 1: 创建 profile_screen.dart**

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('我的', style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.accentBrown,
              )),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    _MenuItem(icon: Icons.download_outlined, label: '导出数据', onTap: () {}),
                    const Divider(height: 1, indent: 56),
                    _MenuItem(icon: Icons.notifications_outlined, label: '每日提醒', onTap: () {}),
                    const Divider(height: 1, indent: 56),
                    _MenuItem(icon: Icons.info_outline, label: '关于心迹', onTap: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '心迹 v1.0.0\n数据仅存储在本地',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.accentBrown),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }
}
```

---

### Task 12: 路由导航 + App 入口

**Covers:** [S6]

**Files:**
- Create: `xinji-app/lib/app/app.dart`
- Create: `xinji-app/lib/app/router.dart`

- [ ] **Step 1: 创建 router.dart**

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../presentation/screens/timeline/timeline_screen.dart';
import '../presentation/screens/write/write_screen.dart';
import '../presentation/screens/insights/insights_screen.dart';
import '../presentation/screens/profile/profile_screen.dart';
import '../presentation/screens/detail/diary_detail_screen.dart';
import '../domain/model/diary_entry.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/timeline',
  routes: [
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        GoRoute(
          path: '/timeline',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const TimelineScreen(),
          ),
        ),
        GoRoute(
          path: '/insights',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const InsightsScreen(),
          ),
        ),
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => NoTransitionPage(
            child: const ProfileScreen(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/write',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const WriteScreen(),
    ),
    GoRoute(
      path: '/diary/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final entry = state.extra as DiaryEntry;
        return DiaryDetailScreen(entry: entry);
      },
    ),
  ],
);

class MainShell extends StatelessWidget {
  final Widget child;

  const MainShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (i) {
          switch (i) {
            case 0: context.go('/timeline');
            case 1: context.go('/insights');
            case 2: context.go('/profile');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.timeline), label: '时间线'),
          BottomNavigationBarItem(icon: Icon(Icons.insights), label: '洞察'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '我的'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/write'),
        child: const Icon(Icons.edit),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    if (location.startsWith('/timeline')) return 0;
    if (location.startsWith('/insights')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }
}
```

- [ ] **Step 2: 创建 app.dart**

```dart
import 'package:flutter/material.dart';
import 'router.dart';
import '../core/theme/app_theme.dart';

class XinjiApp extends StatelessWidget {
  const XinjiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '心迹',
      debugShowCheckedModeBanner: false,
      theme: XinjiTheme.light,
      routerConfig: routerProvider,
    );
  }
}
```

---

### Task 13: 编写测试

**Covers:** [S3]

**Files:**
- Create: `xinji-app/test/domain/model/diary_entry_test.dart`
- Create: `xinji-app/test/presentation/providers/diary_providers_test.dart`

- [ ] **Step 1: 创建 diary_entry_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:xinji_app/domain/model/diary_entry.dart';
import 'package:xinji_app/domain/model/mood_type.dart';

void main() {
  group('DiaryEntry', () {
    test('should create entry with required fields', () {
      final now = DateTime.now();
      final entry = DiaryEntry(
        id: 1,
        content: '今天心情不错',
        moodType: MoodType.happy,
        createdAt: now,
        updatedAt: now,
      );

      expect(entry.id, 1);
      expect(entry.content, '今天心情不错');
      expect(entry.moodType, MoodType.happy);
      expect(entry.photoPaths, isEmpty);
      expect(entry.tags, isEmpty);
    });

    test('should create entry with optional fields', () {
      final now = DateTime.now();
      final entry = DiaryEntry(
        id: 2,
        title: '美好的一天',
        content: '今天天气很好',
        moodType: MoodType.calm,
        createdAt: now,
        updatedAt: now,
        photoPaths: ['photo1.jpg'],
        tags: ['旅行', '自然'],
      );

      expect(entry.title, '美好的一天');
      expect(entry.photoPaths, ['photo1.jpg']);
      expect(entry.tags, ['旅行', '自然']);
    });
  });

  group('MoodType', () {
    test('should have 6 mood types', () {
      expect(MoodType.values.length, 6);
    });

    test('should have labels and emojis', () {
      expect(MoodType.happy.label, '快乐');
      expect(MoodType.happy.emoji, '☀️');
      expect(MoodType.sad.label, '忧伤');
      expect(MoodType.sad.emoji, '🌨');
    });
  });
}
```

- [ ] **Step 2: Run domain tests**

Run: `cd xinji-app && flutter test test/domain/model/diary_entry_test.dart`
Expected: All tests pass

- [ ] **Step 3: 创建 diary_providers_test.dart**

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:xinji_app/domain/model/diary_entry.dart';
import 'package:xinji_app/domain/model/mood_type.dart';
import 'package:xinji_app/domain/repository/diary_repository.dart';

class MockDiaryRepository implements DiaryRepository {
  final List<DiaryEntry> _entries = [];

  @override
  Future<List<DiaryEntry>> getAllEntries() async => _entries;

  @override
  Future<DiaryEntry?> getEntryById(int id) async =>
      _entries.where((e) => e.id == id).firstOrNull;

  @override
  Future<List<DiaryEntry>> getEntriesByDate(DateTime date) async => _entries;

  @override
  Future<List<DiaryEntry>> getEntriesByMood(MoodType mood) async =>
      _entries.where((e) => e.moodType == mood).toList();

  @override
  Future<List<DiaryEntry>> searchEntries(String query) async =>
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
        content: '测试日记',
        moodType: MoodType.happy,
        createdAt: now,
        updatedAt: now,
      ));

      final entries = await repo.getAllEntries();
      expect(entries.length, 1);
      expect(entries.first.content, '测试日记');
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
```

- [ ] **Step 4: Run all tests**

Run: `cd xinji-app && flutter test`
Expected: All tests pass
