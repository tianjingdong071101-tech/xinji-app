import 'package:flutter_test/flutter_test.dart';
import 'package:xinji_app/domain/model/diary_entry.dart';
import 'package:xinji_app/domain/model/mood_type.dart';

void main() {
  group('DiaryEntry', () {
    test('should create entry with required fields', () {
      final now = DateTime.now();
      final entry = DiaryEntry(
        id: 1,
        content: '今天心情不错',
        moodType: MoodType.happy,
        createdAt: now,
        updatedAt: now,
      );

      expect(entry.id, 1);
      expect(entry.content, '今天心情不错');
      expect(entry.moodType, MoodType.happy);
      expect(entry.photoPaths, isEmpty);
      expect(entry.tags, isEmpty);
    });

    test('should create entry with optional fields', () {
      final now = DateTime.now();
      final entry = DiaryEntry(
        id: 2,
        title: '美好的一天',
        content: '今天天气很好',
        moodType: MoodType.calm,
        createdAt: now,
        updatedAt: now,
        photoPaths: ['photo1.jpg'],
        tags: ['旅行', '自然'],
      );

      expect(entry.title, '美好的一天');
      expect(entry.photoPaths, ['photo1.jpg']);
      expect(entry.tags, ['旅行', '自然']);
    });
  });

  group('MoodType', () {
    test('should have 6 mood types', () {
      expect(MoodType.values.length, 6);
    });

    test('should have labels and emojis', () {
      expect(MoodType.happy.label, '快乐');
      expect(MoodType.happy.emoji, '☀️');
      expect(MoodType.sad.label, '忧伤');
      expect(MoodType.sad.emoji, '🌨');
    });
  });
}
