# Calendar Todos Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use compose:subagent (recommended) or compose:execute to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add persistent todo/task functionality to the mood calendar, with per-day bottom sheet management.

**Architecture:** New `Todos` SQLite table + `TodoItem` model + `TodoRepository` (following existing Drift/Riverpod patterns). Calendar grid shows todo count badges; tapping a date opens a bottom sheet for CRUD.

**Tech Stack:** Flutter, Drift, Riverpod 2.x, GoRouter

---

### Task 1: TodoItem domain model

**Files:**
- Create: `lib/domain/model/todo_item.dart`

- [ ] **Step 1: Create TodoItem model**

```dart
import 'package:equatable/equatable.dart';

enum TodoPriority { normal, important }

class TodoItem extends Equatable {
  final int id;
  final String title;
  final String? description;
  final bool completed;
  final TodoPriority priority;
  final DateTime date;
  final DateTime createdAt;

  const TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.completed = false,
    this.priority = TodoPriority.normal,
    required this.date,
    required this.createdAt,
  });

  TodoItem copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    bool clearDescription = false,
    TodoPriority? priority,
    DateTime? date,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, title, description, completed, priority, date, createdAt];
}
```

- [ ] **Step 2: Create TodoRepository interface**

File: `lib/domain/repository/todo_repository.dart`

```dart
import '../model/todo_item.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> getTodosByDate(DateTime date);
  Future<List<TodoItem>> getAllTodos();
  Future<int> insertTodo(TodoItem todo);
  Future<void> updateTodo(TodoItem todo);
  Future<void> deleteTodo(int id);
  Future<void> toggleTodo(int id, bool completed);
  Future<Map<DateTime, int>> getUncompletedCountsByMonth(int year, int month);
}
```

- [ ] **Step 3: Commit**

```bash
git add lib/domain/model/todo_item.dart lib/domain/repository/todo_repository.dart
git commit -m "feat: add TodoItem model and repository interface"
```

---

### Task 2: Database — Todos table

**Covers:** [S1]

**Files:**
- Modify: `lib/data/database/tables.dart` (append Todos table)
- Modify: `lib/data/database/app_database.dart` (bump schemaVersion, add migration, register table)

- [ ] **Step 1: Add Todos table to tables.dart**

Append to `lib/data/database/tables.dart`:

```dart
class Todos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  IntColumn get completed => integer().withDefault(const Constant(0))();
  TextColumn get priority => text().withDefault(const Constant('normal'))();
  IntColumn get date => integer()();
  IntColumn get createdAt => integer()();

  @override
  Set<Index> get indexes => {
    Index('idx_todos_date', 'date'),
  };
}
```

- [ ] **Step 2: Update AppDatabase**

In `lib/data/database/app_database.dart`:
- Add `Todos` to `@DriftDatabase(tables: [DiaryEntries, MoodRecords, Tags, Todos])`
- Bump `schemaVersion` from 2 to 3
- Add migration in `onUpgrade`: from 2 → 3, create the todos table

OldString:
```dart
@DriftDatabase(tables: [DiaryEntries, MoodRecords, Tags])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;
```

NewString:
```dart
@DriftDatabase(tables: [DiaryEntries, MoodRecords, Tags, Todos])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 3;
```

Add migration case inside `onUpgrade`:
OldString:
```dart
      if (from == 1) {
        await customStatement(
          'CREATE TABLE IF NOT EXISTS tags (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL UNIQUE, color TEXT NOT NULL, created_at INTEGER NOT NULL)',
        );
        await customStatement(
          'CREATE TABLE IF NOT EXISTS mood_records (id INTEGER PRIMARY KEY AUTOINCREMENT, date INTEGER NOT NULL, mood_type TEXT NOT NULL, entry_id INTEGER, created_at INTEGER NOT NULL)',
        );
      }
```

NewString:
```dart
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
          'CREATE TABLE IF NOT EXISTS todos (id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT NOT NULL, description TEXT, completed INTEGER NOT NULL DEFAULT 0, priority TEXT NOT NULL DEFAULT \'normal\', date INTEGER NOT NULL, created_at INTEGER NOT NULL)',
        );
        await customStatement(
          'CREATE INDEX IF NOT EXISTS idx_todos_date ON todos(date)',
        );
      }
```

- [ ] **Step 3: Run codegen and verify**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/data/database/tables.dart lib/data/database/app_database.dart
git commit -m "feat: add Todos table with schema migration v3"
```

---

### Task 3: TodoRepository implementation

**Covers:** [S1]

**Files:**
- Create: `lib/data/repository/todo_repository_impl.dart`
- Modify: none

- [ ] **Step 1: Create TodoRepositoryImpl**

File: `lib/data/repository/todo_repository_impl.dart`

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/model/todo_item.dart';
import '../../domain/repository/todo_repository.dart';
import '../database/app_database.dart' as db;

part 'todo_repository_impl.g.dart';

@riverpod
TodoRepository todoRepository(TodoRepositoryRef ref) {
  return TodoRepositoryImpl(ref.watch(db.appDatabaseProvider));
}

class TodoRepositoryImpl implements TodoRepository {
  final db.AppDatabase _db;

  TodoRepositoryImpl(this._db);

  @override
  Future<List<TodoItem>> getTodosByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final rows = await (_db.select(_db.todos)
      ..where((t) => t.date.isBetween(
        Constant(start.millisecondsSinceEpoch),
        Constant(end.millisecondsSinceEpoch - 1),
      ))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
        .get();
    return rows.map(_toItem).toList();
  }

  @override
  Future<List<TodoItem>> getAllTodos() async {
    final rows = await (_db.select(_db.todos)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
    return rows.map(_toItem).toList();
  }

  @override
  Future<int> insertTodo(TodoItem todo) async {
    return await _db.into(_db.todos).insert(db.TodosCompanion(
      title: Value(todo.title),
      description: Value(todo.description),
      completed: Value(todo.completed ? 1 : 0),
      priority: Value(todo.priority.name),
      date: Value(todo.date.millisecondsSinceEpoch),
      createdAt: Value(todo.createdAt.millisecondsSinceEpoch),
    ));
  }

  @override
  Future<void> updateTodo(TodoItem todo) async {
    await (_db.update(_db.todos)
      ..where((t) => t.id.equals(todo.id)))
        .write(db.TodosCompanion(
      title: Value(todo.title),
      description: Value(todo.description),
      completed: Value(todo.completed ? 1 : 0),
      priority: Value(todo.priority.name),
    ));
  }

  @override
  Future<void> deleteTodo(int id) async {
    await (_db.delete(_db.todos)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> toggleTodo(int id, bool completed) async {
    await (_db.update(_db.todos)
      ..where((t) => t.id.equals(id)))
        .write(db.TodosCompanion(
      completed: Value(completed ? 1 : 0),
    ));
  }

  @override
  Future<Map<DateTime, int>> getUncompletedCountsByMonth(int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final rows = await (_db.selectOnly(_db.todos)
      ..addColumns([_db.todos.date, _db.todos.id.count()])
      ..where(_db.todos.date.isBetween(
        Constant(start.millisecondsSinceEpoch),
        Constant(end.millisecondsSinceEpoch - 1),
      ) & _db.todos.completed.equals(0))
      ..groupBy([_db.todos.date])
    ).get();

    final map = <DateTime, int>{};
    for (final row in rows) {
      final ms = row.read(_db.todos.date);
      final count = row.read(_db.todos.id.count()) ?? 0;
      if (ms != null && count > 0) {
        final d = DateTime.fromMillisecondsSinceEpoch(ms);
        map[DateTime(d.year, d.month, d.day)] = count;
      }
    }
    return map;
  }

  TodoItem _toItem(db.Todo row) {
    return TodoItem(
      id: row.id,
      title: row.title,
      description: row.description,
      completed: row.completed == 1,
      priority: TodoPriority.values.firstWhere((p) => p.name == row.priority),
      date: DateTime.fromMillisecondsSinceEpoch(row.date),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    );
  }
}
```

- [ ] **Step 2: Run codegen**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 3: Commit**

```bash
git add lib/data/repository/todo_repository_impl.dart
git commit -m "feat: implement TodoRepository with Drift"
```

---

### Task 4: Todo bottom sheet widget

**Covers:** [S3]

**Files:**
- Create: `lib/presentation/screens/insights/widgets/todo_bottom_sheet.dart`
- Modify: none

- [ ] **Step 1: Create TodoBottomSheet widget**

File: `lib/presentation/screens/insights/widgets/todo_bottom_sheet.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repository/todo_repository_impl.dart';
import '../../../../domain/model/todo_item.dart';

class TodoBottomSheet extends ConsumerStatefulWidget {
  final DateTime date;

  const TodoBottomSheet({super.key, required this.date});

  @override
  ConsumerState<TodoBottomSheet> createState() => _TodoBottomSheetState();
}

class _TodoBottomSheetState extends ConsumerState<TodoBottomSheet> {
  late Future<List<TodoItem>> _todosFuture;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() {
    final repo = ref.read(todoRepositoryProvider);
    _todosFuture = repo.getTodosByDate(widget.date);
  }

  void _refresh() {
    setState(() => _loadTodos());
  }

  void _showAddDialog() {
    final titleCtl = TextEditingController();
    final descCtl = TextEditingController();
    var priority = TodoPriority.normal;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.card,
          title: Text('添加待办', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtl,
                autofocus: true,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '待办内容',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descCtl,
                maxLines: 3,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '描述（可选）',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('优先级', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  SizedBox(width: 12),
                  _PriorityChip(
                    label: '普通',
                    selected: priority == TodoPriority.normal,
                    onTap: () => setDialogState(() => priority = TodoPriority.normal),
                  ),
                  SizedBox(width: 8),
                  _PriorityChip(
                    label: '重要',
                    selected: priority == TodoPriority.important,
                    onTap: () => setDialogState(() => priority = TodoPriority.important),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('取消', style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                if (titleCtl.text.trim().isEmpty) return;
                final repo = ref.read(todoRepositoryProvider);
                await repo.insertTodo(TodoItem(
                  id: 0,
                  title: titleCtl.text.trim(),
                  description: descCtl.text.trim().isEmpty ? null : descCtl.text.trim(),
                  completed: false,
                  priority: priority,
                  date: widget.date,
                  createdAt: DateTime.now(),
                ));
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                _refresh();
              },
              child: Text('添加', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(TodoItem item) {
    final titleCtl = TextEditingController(text: item.title);
    final descCtl = TextEditingController(text: item.description ?? '');
    var priority = item.priority;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.card,
          title: Text('编辑待办', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtl,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '待办内容',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descCtl,
                maxLines: 3,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '描述（可选）',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('优先级', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                  SizedBox(width: 12),
                  _PriorityChip(
                    label: '普通',
                    selected: priority == TodoPriority.normal,
                    onTap: () => setDialogState(() => priority = TodoPriority.normal),
                  ),
                  SizedBox(width: 8),
                  _PriorityChip(
                    label: '重要',
                    selected: priority == TodoPriority.important,
                    onTap: () => setDialogState(() => priority = TodoPriority.important),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('取消', style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                if (titleCtl.text.trim().isEmpty) return;
                final repo = ref.read(todoRepositoryProvider);
                await repo.updateTodo(item.copyWith(
                  title: titleCtl.text.trim(),
                  description: descCtl.text.trim().isEmpty ? null : descCtl.text.trim(),
                  priority: priority,
                ));
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                _refresh();
              },
              child: Text('保存', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.textMuted.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${widget.date.month}月${widget.date.day}日 待办',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Spacer(),
                GestureDetector(
                  onTap: _showAddDialog,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('新建', style: TextStyle(fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Flexible(
            child: FutureBuilder<List<TodoItem>>(
              future: _todosFuture,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator(color: AppColors.accent));
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Text('📝', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 8),
                        Text('暂无待办', style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 20),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _TodoTile(
                    item: items[i],
                    onToggle: () async {
                      final repo = ref.read(todoRepositoryProvider);
                      await repo.toggleTodo(items[i].id, !items[i].completed);
                      _refresh();
                    },
                    onEdit: () => _showEditDialog(items[i]),
                    onDelete: () async {
                      final repo = ref.read(todoRepositoryProvider);
                      await repo.deleteTodo(items[i].id);
                      _refresh();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 12,
          color: selected ? AppColors.accent : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        )),
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TodoTile({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  color: item.completed ? AppColors.moodCalm : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: item.completed ? AppColors.moodCalm : AppColors.textMuted,
                    width: 1.5,
                  ),
                ),
                child: item.completed
                    ? Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.priority == TodoPriority.important)
                        Container(
                          margin: EdgeInsets.only(right: 6),
                          padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.moodAnxious.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('重要', style: TextStyle(
                            fontSize: 10, color: AppColors.moodAnxious, fontWeight: FontWeight.w600,
                          )),
                        ),
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            decoration: item.completed ? TextDecoration.lineThrough : null,
                            color: item.completed ? AppColors.textMuted : AppColors.textPrimary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (item.description != null && item.description!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        item.description!,
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.delete_outline, size: 18, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

- [ ] **Step 2: Commit**

```bash
git add lib/presentation/screens/insights/widgets/todo_bottom_sheet.dart
git commit -m "feat: add TodoBottomSheet widget with CRUD"
```

---

### Task 5: Integrate todos into MoodCalendarGrid

**Covers:** [S3]

**Files:**
- Modify: `lib/presentation/screens/insights/widgets/mood_calendar_grid.dart`
- Modify: `lib/presentation/screens/insights/insights_screen.dart`

- [ ] **Step 1: Update MoodCalendarGrid to accept and display todo counts**

Changes to `mood_calendar_grid.dart`:

Add new parameter `todoCounts`:
OldString:
```dart
class MoodCalendarGrid extends StatefulWidget {
  final DateTime initialMonth;
  final void Function(DateTime)? onDayTap;
  final Map<DateTime, MoodType> dailyMoods;

  const MoodCalendarGrid({
    super.key,
    required this.initialMonth,
    this.onDayTap,
    this.dailyMoods = const {},
  });
```

NewString:
```dart
class MoodCalendarGrid extends StatefulWidget {
  final DateTime initialMonth;
  final void Function(DateTime)? onDayTap;
  final Map<DateTime, MoodType> dailyMoods;
  final Map<DateTime, int> todoCounts;

  const MoodCalendarGrid({
    super.key,
    required this.initialMonth,
    this.onDayTap,
    this.dailyMoods = const {},
    this.todoCounts = const {},
  });
```

Inside the day cell builder, after the mood dot, add todo badge. Find the `Container` with `width: 6, height: 6` for the mood dot, and below it add:

OldString:
```dart
                        if (mood != null)
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: mood.color,
                              shape: BoxShape.circle,
                            ),
                          ),
```

NewString:
```dart
                        SizedBox(height: 2),
                        if (mood != null)
                          Container(
                            width: 6, height: 6,
                            decoration: BoxDecoration(
                              color: mood.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        if (todoCounts.containsKey(date) && todoCounts[date]! > 0)
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${todoCounts[date]}',
                              style: TextStyle(fontSize: 9, color: AppColors.accent, fontWeight: FontWeight.w600),
                            ),
                          ),
```

You also need to add the import for AppColors at the top (it's already imported).

- [ ] **Step 2: Update InsightsScreen to pass todo counts to calendar**

In `lib/presentation/screens/insights/insights_screen.dart`:

Add a riverpod provider for todo monthly counts and wire it to the calendar grid.

Add import:
```dart
import '../../../data/repository/todo_repository_impl.dart';
```

Add provider at bottom of file:
```dart
@riverpod
Future<Map<DateTime, int>> _monthlyTodoCounts(_MonthlyTodoCountsRef ref) async {
  final repo = ref.watch(todoRepositoryProvider);
  final now = DateTime.now();
  return repo.getUncompletedCountsByMonth(now.year, now.month);
}
```

In the build method of `_InsightsScreenState`, watch this provider and pass it to `MoodCalendarGrid`:

Find:
```dart
                if (_selectedTab == 1)
                  Container(
                    ...
                    child: dailyMoodsAsync.when(
                      data: (moods) => MoodCalendarGrid(
                        initialMonth: DateTime.now(),
                        dailyMoods: moods.entries
                          ...
```

Change to:
```dart
                if (_selectedTab == 1)
                  Container(
                    ...
                    child: dailyMoodsAsync.when(
                      data: (moods) {
                        final todoCountsAsync = ref.watch(_monthlyTodoCountsProvider);
                        return todoCountsAsync.when(
                          data: (todoCounts) => MoodCalendarGrid(
                            initialMonth: DateTime.now(),
                            dailyMoods: moods.entries
                              .where((e) => e.value != null)
                              .fold<Map<DateTime, MoodType>>({}, (map, e) {
                                map[e.key] = e.value!;
                                return map;
                              }),
                            todoCounts: todoCounts,
                            onDayTap: (date) async {
                              final repo = ref.read(diaryRepositoryProvider);
                              final entries = await repo.getEntriesByDate(date);
                              if (!context.mounted) return;
                              showModalBottomSheet(
                                context: context,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                                builder: (_) => TodoBottomSheet(date: date),
                              );
                            },
                          ),
                          loading: () => Center(child: CircularProgressIndicator(color: AppColors.accent)),
                          error: (_, __) => Center(child: Text('加载失败')),
                        );
                      },
```

- [ ] **Step 3: Run codegen**

```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] **Step 4: Commit**

```bash
git add lib/presentation/screens/insights/widgets/mood_calendar_grid.dart lib/presentation/screens/insights/insights_screen.dart
git commit -m "feat: integrate todo badges into calendar and todo bottom sheet on day tap"
```

---

### Task 6: Verify and fix

**Files:** none

- [ ] **Step 1: Run the analyzer**

```bash
flutter analyze --no-fatal-warnings
```

- [ ] **Step 2: Fix any issues**

If analyzer reports errors, fix them in the respective files.

- [ ] **Step 3: Final commit**

```bash
git add -A
git commit -m "fix: resolve analyzer issues"
```
