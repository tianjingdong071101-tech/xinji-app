import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:drift/drift.dart';
import '../../domain/model/tag.dart';
import '../../domain/repository/tag_repository.dart';
import '../database/app_database.dart' as db;
import '../database/tables.dart';

part 'tag_repository_impl.g.dart';

@riverpod
TagRepository tagRepository(TagRepositoryRef ref) {
  return TagRepositoryImpl(ref.watch(appDatabaseProvider));
}

class TagRepositoryImpl implements TagRepository {
  final AppDatabase _db;

  TagRepositoryImpl(this._db);

  @override
  Future<List<Tag>> getAllTags() async {
    final rows = await _db.select(_db.tags).get();
    return rows.map((r) => Tag(
      id: r.id,
      name: r.name,
      color: r.color,
      createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
    )).toList();
  }

  @override
  Future<Tag?> getTagByName(String name) async {
    final row = await (_db.select(_db.tags)
      ..where((t) => t.name.equals(name)))
        .getSingleOrNull();
    return row != null ? Tag(
      id: row.id, name: row.name,
      color: row.color,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    ) : null;
  }

  @override
  Future<int> insertTag(Tag tag) async {
    return await _db.into(_db.tags).insert(TagsCompanion(
      name: Value(tag.name),
      color: Value(tag.color),
      createdAt: Value(tag.createdAt.millisecondsSinceEpoch),
    ));
  }

  @override
  Future<void> deleteTag(int id) async {
    await (_db.delete(_db.tags)..where((t) => t.id.equals(id))).go();
  }
}
