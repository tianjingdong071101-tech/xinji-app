import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

part 'reminder_engine.g.dart';

class ReminderEngine {
  final FlutterLocalNotificationsPlugin _plugin;
  bool _initialized = false;
  int? _reminderHour;
  int? _reminderMinute;

  ReminderEngine() : _plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    if (_initialized) return;
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
    await _plugin.show(
      0,
      '心迹',
      '该写随笔了，今天的心情怎么样？',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder',
          '每日随笔提醒',
          channelDescription: '每天提醒你记录心情和随笔',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
        iOS: DarwinNotificationDetails(),
      ),
    );
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
