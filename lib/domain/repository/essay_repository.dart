import '../model/essay_entry.dart';
import '../model/mood_type.dart';

abstract class DiaryRepository {
  Future<List<DiaryEntry>> getAllEntries({int? limit, int? offset});
  Future<DiaryEntry?> getEntryById(int id);
  Future<List<DiaryEntry>> getEntriesByDate(DateTime date);
  Future<List<DiaryEntry>> getEntriesByDateRange(DateTime start, DateTime end);
  Future<List<DiaryEntry>> getEntriesByMood(MoodType mood);
  Future<List<DiaryEntry>> searchEntries(String query, {int? limit});
  Future<int> insertEntry(DiaryEntry entry);
  Future<void> updateEntry(DiaryEntry entry);
  Future<void> deleteEntry(int id);
  Future<int> getEntryCount();
  Future<int> getStreakCount();
}
