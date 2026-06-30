import 'package:equatable/equatable.dart';
import 'mood_type.dart';

class DiaryEntry extends Equatable {
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

  DiaryEntry copyWith({
    int? id,
    String? title,
    bool clearTitle = false,
    String? content,
    MoodType? moodType,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? weatherTag,
    bool clearWeatherTag = false,
    List<String>? photoPaths,
    String? audioPath,
    bool clearAudioPath = false,
    List<String>? tags,
  }) {
    return DiaryEntry(
      id: id ?? this.id,
      title: clearTitle ? null : (title ?? this.title),
      content: content ?? this.content,
      moodType: moodType ?? this.moodType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      weatherTag: clearWeatherTag ? null : (weatherTag ?? this.weatherTag),
      photoPaths: photoPaths ?? this.photoPaths,
      audioPath: clearAudioPath ? null : (audioPath ?? this.audioPath),
      tags: tags ?? this.tags,
    );
  }

  @override
  List<Object?> get props => [id, title, content, moodType, createdAt, updatedAt, weatherTag, photoPaths, audioPath, tags];
}
