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
