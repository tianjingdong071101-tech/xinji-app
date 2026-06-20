import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repository/diary_repository_impl.dart';
import '../../domain/model/diary_entry.dart';

part 'diary_providers.g.dart';

@riverpod
class DiaryList extends _$DiaryList {
  @override
  Future<List<DiaryEntry>> build() async {
    final repo = ref.watch(diaryRepositoryProvider);
    return repo.getAllEntries();
  }

  Future<void> refresh() async {
    ref.invalidateSelf();
  }
}

@riverpod
class DiarySearch extends _$DiarySearch {
  @override
  Future<List<DiaryEntry>> build(String query) async {
    if (query.isEmpty) return [];
    final repo = ref.watch(diaryRepositoryProvider);
    return repo.searchEntries(query);
  }
}
