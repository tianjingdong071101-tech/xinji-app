import '../model/tag.dart';

abstract class TagRepository {
  Future<List<Tag>> getAllTags();
  Future<Tag?> getTagByName(String name);
  Future<int> insertTag(Tag tag);
  Future<void> deleteTag(int id);
}
