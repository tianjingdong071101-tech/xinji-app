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
