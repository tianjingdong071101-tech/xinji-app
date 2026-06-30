import '../model/mood_record.dart';
import '../model/mood_type.dart';

abstract class MoodRepository {
  Future<List<MoodRecord>> getMoodRecords(DateTime start, DateTime end);
  Future<Map<MoodType, int>> getMoodDistribution(
    DateTime start, DateTime end,
  );
  Future<int> insertRecord(MoodRecord record);
}
