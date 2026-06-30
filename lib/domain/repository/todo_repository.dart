import '../model/todo_item.dart';

abstract class TodoRepository {
  Future<List<TodoItem>> getTodosByDate(DateTime date);
  Future<List<TodoItem>> getAllTodos();
  Future<int> insertTodo(TodoItem todo);
  Future<void> updateTodo(TodoItem todo);
  Future<void> deleteTodo(int id);
  Future<void> toggleTodo(int id, bool completed);
  Future<Map<DateTime, int>> getUncompletedCountsByMonth(
      int year, int month);
}
