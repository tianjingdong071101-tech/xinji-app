import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/repository/essay_repository_impl.dart';
import '../../../data/repository/mood_repository_impl.dart';
import '../../../domain/model/essay_entry.dart';
import '../../../domain/model/mood_record.dart';
import '../../../domain/model/mood_type.dart';
import '../../../domain/repository/essay_repository.dart';
import '../../../domain/repository/mood_repository.dart';

final writeDiaryProvider = StateNotifierProvider<WriteDiaryNotifier, WriteDiaryState>((ref) {
  return WriteDiaryNotifier(ref.watch(diaryRepositoryProvider), ref.watch(moodRepositoryProvider));
});

class WriteDiaryState {
  final String title;
  final String content;
  final MoodType? mood;
  final List<String> tags;
  final List<String> photoPaths;
  final String? audioPath;
  final bool isSaving;
  final String? error;

  const WriteDiaryState({
    this.title = '',
    this.content = '',
    this.mood,
    this.tags = const [],
    this.photoPaths = const [],
    this.audioPath,
    this.isSaving = false,
    this.error,
  });

  WriteDiaryState copyWith({
    String? title,
    String? content,
    MoodType? mood,
    List<String>? tags,
    List<String>? photoPaths,
    String? audioPath,
    bool? isSaving,
    String? error,
    bool clearMood = false,
    bool clearError = false,
    bool clearAudioPath = false,
  }) {
    return WriteDiaryState(
      title: title ?? this.title,
      content: content ?? this.content,
      mood: clearMood ? null : (mood ?? this.mood),
      tags: tags ?? this.tags,
      photoPaths: photoPaths ?? this.photoPaths,
      audioPath: clearAudioPath ? null : (audioPath ?? this.audioPath),
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WriteDiaryNotifier extends StateNotifier<WriteDiaryState> {
  final DiaryRepository _repo;
  final MoodRepository _moodRepo;

  WriteDiaryNotifier(this._repo, this._moodRepo) : super(const WriteDiaryState());

  void updateTitle(String title) => state = state.copyWith(title: title);
  void updateContent(String content) => state = state.copyWith(content: content);
  void selectMood(MoodType mood) => state = state.copyWith(mood: mood);
  void addTag(String tag) => state = state.copyWith(tags: [...state.tags, tag]);
  void removeTag(String tag) => state = state.copyWith(
    tags: state.tags.where((t) => t != tag).toList(),
  );
  void addPhoto(String path) => state = state.copyWith(photoPaths: [...state.photoPaths, path]);
  void removePhoto(String path) => state = state.copyWith(photoPaths: state.photoPaths.where((p) => p != path).toList());
  void setAudioPath(String? path) => state = state.copyWith(audioPath: path, clearAudioPath: path == null);

  Future<bool> save() async {
    if (state.mood == null || state.content.isEmpty) return false;
    state = state.copyWith(isSaving: true, clearError: true);
    try {
      final now = DateTime.now();
      final entry = DiaryEntry(
        id: 0,
        title: state.title.isNotEmpty ? state.title : null,
        content: state.content,
        moodType: state.mood!,
        createdAt: now,
        updatedAt: now,
        photoPaths: state.photoPaths,
        audioPath: state.audioPath,
        tags: state.tags,
      );
      final entryId = await _repo.insertEntry(entry);
      await _moodRepo.insertRecord(MoodRecord(
        id: 0, date: now, moodType: state.mood!,
        entryId: entryId, createdAt: now,
      ));
      state = const WriteDiaryState();
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: '保存失败，请重试');
      return false;
    }
  }

  void reset() => state = const WriteDiaryState();
}
