import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/model/mood_type.dart';
import '../../../engine/search_engine.dart';
import '../../widgets/essay_card.dart';

final _queryProvider = StateProvider<String>((ref) => '');
final _moodFilterProvider = StateProvider<MoodType?>((ref) => null);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  List<SearchResult>? _results;
  bool _loading = false;

  void _search() {
    final query = ref.read(_queryProvider);
    final moodFilter = ref.read(_moodFilterProvider);
    if (query.isEmpty) { setState(() { _results = null; _loading = false; }); return; }
    setState(() => _loading = true);
    ref.read(searchEngineProvider).search(query: query, moodFilter: moodFilter).then((r) {
      if (mounted) setState(() { _results = r; _loading = false; });
    });
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(_queryProvider);
    final moodFilter = ref.watch(_moodFilterProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: TextField(
          autofocus: true,
          onChanged: (v) { ref.read(_queryProvider.notifier).state = v; _search(); },
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '搜索随笔内容、标题...',
            hintStyle: TextStyle(color: AppColors.textMuted),
            border: InputBorder.none,
          ),
        ),
        actions: [
          if (query.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: AppColors.textMuted),
              onPressed: () { ref.read(_queryProvider.notifier).state = ''; setState(() { _results = null; _loading = false; }); },
            ),
        ],
      ),
      body: Column(
        children: [
          if (query.isNotEmpty)
            Container(
              height: 48,
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: MoodType.values.map((mood) {
                  final selected = moodFilter == mood;
                  return Padding(
                    padding: EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () { ref.read(_moodFilterProvider.notifier).state = selected ? null : mood; _search(); },
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? mood.color.withValues(alpha: 0.15) : AppColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: selected ? mood.color : AppColors.borderLight, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(mood.emoji, style: TextStyle(fontSize: 14)),
                            SizedBox(width: 4),
                            Text(mood.label, style: TextStyle(fontSize: 12, color: selected ? mood.color : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: query.isEmpty
                ? Center(child: Text('输入关键词搜索随笔', style: TextStyle(color: AppColors.textMuted)))
                : _loading
                    ? Center(child: CircularProgressIndicator(color: AppColors.accent))
                    : _results == null
                        ? Center(child: CircularProgressIndicator(color: AppColors.accent))
                        : _results!.isEmpty
                            ? Center(child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text('😕', style: TextStyle(fontSize: 40)),
                                  SizedBox(height: 12),
                                  Text('没有找到匹配的随笔', style: TextStyle(color: AppColors.textMuted)),
                                ],
                              ))
                            : ListView.builder(
                                padding: EdgeInsets.only(top: 8, bottom: 80),
                                itemCount: _results!.length,
                                itemBuilder: (_, i) => EssayCard(
                                  entry: _results![i].entry,
                                  highlightTerms: query.split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList(),
                                  onTap: () => context.push('/essay/${_results![i].entry.id}', extra: _results![i].entry),
                                ),
                              ),
          ),
        ],
      ),
    );
  }
}
