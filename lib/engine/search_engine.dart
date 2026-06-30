import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/repository/essay_repository_impl.dart';
import '../domain/model/essay_entry.dart';
import '../domain/model/mood_type.dart';
import '../domain/repository/essay_repository.dart';

part 'search_engine.g.dart';

class SearchResult {
  final DiaryEntry entry;
  final List<String> matchedTerms;
  const SearchResult({required this.entry, required this.matchedTerms});
}

class SearchEngine {
  final DiaryRepository _repo;
  SearchEngine(this._repo);

  Future<List<SearchResult>> search({
    required String query,
    MoodType? moodFilter,
  }) async {
    if (query.trim().isEmpty) return [];
    final entries = await _repo.searchEntries(query.trim());
    final terms = query.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    var filtered = entries;
    if (moodFilter != null) {
      filtered = filtered.where((e) => e.moodType == moodFilter).toList();
    }
    return filtered.map((e) {
      return SearchResult(
        entry: e,
        matchedTerms: terms.where((t) {
          final lower = t.toLowerCase();
          return e.content.toLowerCase().contains(lower) || (e.title?.toLowerCase().contains(lower) ?? false);
        }).toList(),
      );
    }).toList();
  }
}

@riverpod
SearchEngine searchEngine(SearchEngineRef ref) {
  return SearchEngine(ref.watch(diaryRepositoryProvider));
}
