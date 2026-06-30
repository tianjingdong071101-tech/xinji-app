import 'package:drift/drift.dart';
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
      ..orderBy([
        (t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)
      ]))
        .get();
    return rows.map(_toItem).toList();
  }

  @override
  Future<List<TodoItem>> getAllTodos() async {
    final rows = await (_db.select(_db.todos)
      ..orderBy([
        (t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)
      ]))
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
          recurring: Value(todo.recurring.name),
          date: Value(todo.date.millisecondsSinceEpoch),
          createdAt: Value(todo.createdAt.millisecondsSinceEpoch),
        ));
  }

  @override
  Future<void> updateTodo(TodoItem todo) async {
    await (_db.update(_db.todos)..where((t) => t.id.equals(todo.id)))
        .write(db.TodosCompanion(
      title: Value(todo.title),
      description: Value(todo.description),
      completed: Value(todo.completed ? 1 : 0),
      priority: Value(todo.priority.name),
      recurring: Value(todo.recurring.name),
    ));
  }

  @override
  Future<void> deleteTodo(int id) async {
    await (_db.delete(_db.todos)..where((t) => t.id.equals(id))).go();
  }

  @override
  Future<void> toggleTodo(int id, bool completed) async {
    await (_db.update(_db.todos)..where((t) => t.id.equals(id)))
        .write(db.TodosCompanion(
      completed: Value(completed ? 1 : 0),
    ));
  }

  @override
  Future<Map<DateTime, int>> getUncompletedCountsByMonth(
      int year, int month) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 1);
    final rows = await (_db.selectOnly(_db.todos)
      ..addColumns([_db.todos.date, _db.todos.id.count()])
      ..where(_db.todos.date.isBetween(
            Constant(start.millisecondsSinceEpoch),
            Constant(end.millisecondsSinceEpoch - 1),
          ) &
          _db.todos.completed.equals(0))
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
      recurring: TodoRecurring.values.firstWhere((r) => r.name == row.recurring),
      date: DateTime.fromMillisecondsSinceEpoch(row.date),
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    );
  }
}
