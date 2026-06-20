import 'mood_type.dart';

class DiaryEntry {
  final int id;
  final String? title;
  final String content;
  final MoodType moodType;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? weatherTag;
  final List<String> photoPaths;
  final String? audioPath;
  final List<String> tags;

  const DiaryEntry({
    required this.id,
    this.title,
    required this.content,
    required this.moodType,
    required this.createdAt,
    required this.updatedAt,
    this.weatherTag,
    this.photoPaths = const [],
    this.audioPath,
    this.tags = const [],
  });
}
