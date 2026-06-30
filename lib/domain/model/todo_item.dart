import 'package:equatable/equatable.dart';

enum TodoPriority { normal, important }

enum TodoRecurring { none, daily, weekdays, weekly }

class TodoItem extends Equatable {
  final int id;
  final String title;
  final String? description;
  final bool completed;
  final TodoPriority priority;
  final TodoRecurring recurring;
  final DateTime date;
  final int? todoTimeMinutes;
  final DateTime createdAt;

  const TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.completed = false,
    this.priority = TodoPriority.normal,
    this.recurring = TodoRecurring.none,
    required this.date,
    this.todoTimeMinutes,
    required this.createdAt,
  });

  String get timeString {
    if (todoTimeMinutes == null) return '';
    final h = todoTimeMinutes! ~/ 60;
    final m = todoTimeMinutes! % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }

  int get timeHour => todoTimeMinutes != null ? todoTimeMinutes! ~/ 60 : 0;
  int get timeMinute => todoTimeMinutes != null ? todoTimeMinutes! % 60 : 0;

  TodoItem copyWith({
    int? id,
    String? title,
    String? description,
    bool? completed,
    bool clearDescription = false,
    TodoPriority? priority,
    TodoRecurring? recurring,
    DateTime? date,
    int? todoTimeMinutes,
    bool clearTime = false,
    DateTime? createdAt,
  }) {
    return TodoItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: clearDescription ? null : (description ?? this.description),
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      recurring: recurring ?? this.recurring,
      date: date ?? this.date,
      todoTimeMinutes: clearTime ? null : (todoTimeMinutes ?? this.todoTimeMinutes),
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props =>
      [id, title, description, completed, priority, recurring, date, todoTimeMinutes, createdAt];
}
