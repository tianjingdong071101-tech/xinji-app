import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

part 'reminder_engine.g.dart';

class TodoReminderData {
  final int todoId;
  final String title;
  final int hour;
  final int minute;

  const TodoReminderData({
    required this.todoId,
    required this.title,
    required this.hour,
    required this.minute,
  });
}

class ReminderEngine {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  bool _tzInitialized = false;
  int? _reminderHour;
  int? _reminderMinute;
  int _nextTodoNotificationId = 1000;

  ReminderEngine() : _plugin = FlutterLocalNotificationsPlugin();

  Future<void> _initTz() async {
    if (_tzInitialized) return;
    tz.initializeTimeZones();
    _tzInitialized = true;
  }

  tz.TZDateTime _tzNow() {
    return tz.TZDateTime.now(tz.local);
  }

  tz.TZDateTime _nextDailyDate(int hour, int minute) {
    final now = _tzNow();
    var next = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (next.isBefore(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  Future<void> init() async {
    if (_initialized) return;
    await _initTz();
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );
    _initialized = true;
  }

  int? get reminderHour => _reminderHour;
  int? get reminderMinute => _reminderMinute;
  bool get hasReminder => _reminderHour != null;

  String getReminderTimeString() {
    if (_reminderHour == null || _reminderMinute == null) return '未设置';
    return '${_reminderHour.toString().padLeft(2, '0')}:${_reminderMinute.toString().padLeft(2, '0')}';
  }

  Future<void> scheduleDaily(int hour, int minute) async {
    await init();
    _reminderHour = hour;
    _reminderMinute = minute;
    await _plugin.cancelAll();
    await _plugin.zonedSchedule(
      0,
      '心迹',
      '你有待办事项待处理，记得查看并记录今天的心情',
      _nextDailyDate(hour, minute),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          '每日待办提醒',
          channelDescription: '每天提醒你查看待办和记录心情',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> scheduleTodoReminder(TodoReminderData data) async {
    await init();
    final now = _tzNow();
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, data.hour, data.minute);
    if (when.isBefore(now)) {
      when = when.add(const Duration(days: 1));
    }
    final id = _nextTodoNotificationId++;
    await _plugin.zonedSchedule(
      id,
      '待办提醒: ${data.title}',
      '你有一条待办事项需要处理',
      when,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'todo_reminder',
          '待办事项提醒',
          channelDescription: '按设定时间提醒待办事项',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> cancelTodoReminder(int notificationId) async {
    await _plugin.cancel(notificationId);
  }

  Future<void> cancel() async {
    _reminderHour = null;
    _reminderMinute = null;
    await _plugin.cancelAll();
  }
}

@riverpod
ReminderEngine reminderEngine(ReminderEngineRef ref) {
  return ReminderEngine();
}
