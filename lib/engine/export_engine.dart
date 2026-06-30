import 'dart:convert';
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:path_provider/path_provider.dart';
import '../data/repository/essay_repository_impl.dart';
import '../data/repository/tag_repository_impl.dart';
import '../domain/repository/essay_repository.dart';
import '../domain/repository/tag_repository.dart';

part 'export_engine.g.dart';

enum ExportFormat { json, csv }

class ExportEngine {
  final DiaryRepository _diaryRepo;
  final TagRepository _tagRepo;
  ExportEngine(this._diaryRepo, this._tagRepo);

  Future<String> export(ExportFormat format) async {
    final entries = await _diaryRepo.getAllEntries();
    final tags = await _tagRepo.getAllTags();

    final dir = await getApplicationDocumentsDirectory();
    final fileName = '心迹_${DateTime.now().millisecondsSinceEpoch}.${format.name}';
    final file = File('${dir.path}/$fileName');

    switch (format) {
      case ExportFormat.json:
        final data = {
          'app': '心迹',
          'version': '1.0.0',
          'exportedAt': DateTime.now().toIso8601String(),
          'entries': entries.map((e) => {
            'id': e.id,
            'title': e.title,
            'content': e.content,
            'moodType': e.moodType.name,
            'moodLabel': e.moodType.label,
            'createdAt': e.createdAt.toIso8601String(),
            'tags': e.tags,
          }).toList(),
          'tags': tags.map((t) => {
            'name': t.name,
            'color': t.color,
          }).toList(),
        };
        await file.writeAsString(const JsonEncoder.withIndent('  ').convert(data), flush: true);
      case ExportFormat.csv:
        final lines = <String>['id,title,content,moodType,createdAt,tags'];
        for (final e in entries) {
          final title = e.title?.contains(',') == true ? '"${e.title}"' : (e.title ?? '');
          final content = e.content.contains(',') ? '"${e.content}"' : e.content;
          lines.add('${e.id},$title,$content,${e.moodType.name},${e.createdAt.toIso8601String()},"${e.tags.join(';')}"');
        }
        await file.writeAsString('${lines.join('\n')}\n', flush: true);
    }
    return file.path;
  }
}

@riverpod
ExportEngine exportEngine(ExportEngineRef ref) {
  return ExportEngine(
    ref.watch(diaryRepositoryProvider),
    ref.watch(tagRepositoryProvider),
  );
}
