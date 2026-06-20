import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/model/mood_type.dart';

class WriteDiaryState {
  final String title;
  final String content;
  final MoodType? mood;
  final List<String> tags;
  final List<String> photoPaths;
  final bool isSaving;
  final bool saved;

  const WriteDiaryState({
    this.title = '',
    this.content = '',
    this.mood,
    this.tags = const [],
    this.photoPaths = const [],
    this.isSaving = false,
    this.saved = false,
  });

  WriteDiaryState copyWith({
    String? title,
    String? content,
    MoodType? mood,
    List<String>? tags,
    List<String>? photoPaths,
    bool? isSaving,
    bool? saved,
    bool clearMood = false,
  }) {
    return WriteDiaryState(
      title: title ?? this.title,
      content: content ?? this.content,
      mood: clearMood ? null : (mood ?? this.mood),
      tags: tags ?? this.tags,
      photoPaths: photoPaths ?? this.photoPaths,
      isSaving: isSaving ?? this.isSaving,
      saved: saved ?? this.saved,
    );
  }
}

class WriteDiaryNotifier extends StateNotifier<WriteDiaryState> {
  WriteDiaryNotifier() : super(const WriteDiaryState());

  void updateTitle(String title) => state = state.copyWith(title: title);
  void updateContent(String content) => state = state.copyWith(content: content);
  void selectMood(MoodType mood) => state = state.copyWith(mood: mood);
  void addTag(String tag) => state = state.copyWith(tags: [...state.tags, tag]);
  void removeTag(String tag) => state = state.copyWith(
    tags: state.tags.where((t) => t != tag).toList(),
  );
  void addPhoto(String path) => state = state.copyWith(
    photoPaths: [...state.photoPaths, path],
  );
  void removePhoto(String path) => state = state.copyWith(
    photoPaths: state.photoPaths.where((p) => p != path).toList(),
  );
  void reset() => state = const WriteDiaryState();
}
