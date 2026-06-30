import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../core/theme/app_colors.dart';
import '../../../core/util/date_util.dart';
import '../../../domain/model/essay_entry.dart';
import '../../../domain/model/mood_type.dart';
import '../../../data/repository/essay_repository_impl.dart';
import '../../widgets/photo_gallery.dart';
import '../../widgets/audio_player.dart';
import '../../widgets/mood_picker.dart';

class DiaryDetailScreen extends ConsumerStatefulWidget {
  final DiaryEntry entry;
  const DiaryDetailScreen({super.key, required this.entry});

  @override
  ConsumerState<DiaryDetailScreen> createState() => _DiaryDetailScreenState();
}

class _DiaryDetailScreenState extends ConsumerState<DiaryDetailScreen> {
  late bool _editing;
  late String _title;
  late String _content;
  late MoodType _mood;
  late List<String> _tags;
  late List<String> _photos;

  @override
  void initState() {
    super.initState();
    _editing = false;
    _title = widget.entry.title ?? '';
    _content = widget.entry.content;
    _mood = widget.entry.moodType;
    _tags = List.from(widget.entry.tags);
    _photos = List.from(widget.entry.photoPaths);
  }

  Future<void> _save() async {
    final now = DateTime.now();
    final updated = widget.entry.copyWith(
      title: _title.isEmpty ? null : _title,
      content: _content,
      moodType: _mood,
      updatedAt: now,
      photoPaths: _photos,
      tags: _tags,
    );
    final repo = ref.read(diaryRepositoryProvider);
    await repo.updateEntry(updated);
    setState(() => _editing = false);
  }

  void _cancel() {
    setState(() {
      _editing = false;
      _title = widget.entry.title ?? '';
      _content = widget.entry.content;
      _mood = widget.entry.moodType;
      _tags = List.from(widget.entry.tags);
      _photos = List.from(widget.entry.photoPaths);
    });
  }

  @override
  Widget build(BuildContext context) {
    final entry = _editing ? widget.entry.copyWith(
      title: _title.isEmpty ? null : _title,
      content: _content,
      moodType: _mood,
      photoPaths: _photos,
      tags: _tags,
    ) : widget.entry;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Text(_editing ? '编辑随笔' : '随笔详情', style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          if (_editing)
            Row(
              children: [
                TextButton(onPressed: _cancel, child: Text('取消', style: TextStyle(color: AppColors.textMuted))),
                TextButton(onPressed: _save, child: Text('保存', style: TextStyle(color: AppColors.accent))),
              ],
            )
          else
            IconButton(
              icon: Icon(Icons.edit_outlined, color: AppColors.accent),
              onPressed: () => setState(() => _editing = true),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_editing)
              MoodPicker(selectedMood: _mood, onMoodSelected: (m) => setState(() => _mood = m))
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight, width: 0.5),
                ),
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        color: entry.moodType.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: entry.moodType.color.withValues(alpha: 0.3), width: 1),
                      ),
                      child: Center(child: Text(entry.moodType.emoji, style: TextStyle(fontSize: 22))),
                    ),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${DateUtil.formatDate(entry.createdAt)} ${DateUtil.weekday(entry.createdAt)}',
                          style: Theme.of(context).textTheme.bodyMedium),
                        Text(entry.moodType.label, style: TextStyle(color: entry.moodType.color, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
            SizedBox(height: 16),
            if (_editing)
              TextField(
                controller: TextEditingController(text: _title)..selection = TextSelection.fromPosition(TextPosition(offset: _title.length)),
                onChanged: (v) => _title = v,
                style: Theme.of(context).textTheme.headlineLarge,
                decoration: InputDecoration(hintText: '标题（可选）', border: InputBorder.none, hintStyle: TextStyle(color: AppColors.textMuted)),
              )
            else if (entry.title != null && entry.title!.isNotEmpty)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(entry.title!, style: Theme.of(context).textTheme.headlineLarge),
              ),
            if (_editing)
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight, width: 0.5),
                ),
                child: TextField(
                  controller: TextEditingController(text: _content)..selection = TextSelection.fromPosition(TextPosition(offset: _content.length)),
                  onChanged: (v) => _content = v,
                  maxLines: null, minLines: 10,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: InputDecoration(
                    hintText: '编辑内容...', border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16), hintStyle: TextStyle(color: AppColors.textMuted),
                  ),
                ),
              )
            else
              Container(
                decoration: BoxDecoration(
                  color: AppColors.card, borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight, width: 0.5),
                ),
                padding: EdgeInsets.all(16),
                child: Text(entry.content, style: Theme.of(context).textTheme.bodyLarge),
              ),
            if (_editing) ...[
              SizedBox(height: 12),
              GestureDetector(
                onTap: () async {
                  final photo = await ImagePicker().pickImage(source: ImageSource.gallery);
                  if (photo != null) setState(() => _photos.add(photo.path));
                },
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: AppColors.cardLight, borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.add_photo_alternate, color: AppColors.textMuted),
                    SizedBox(width: 8), Text('添加照片', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                  ]),
                ),
              ),
              if (_photos.isNotEmpty) ...[
                SizedBox(height: 8),
                Wrap(spacing: 8, runSpacing: 8, children: _photos.map((p) => Stack(children: [
                  ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.file(File(p), width: 64, height: 64, fit: BoxFit.cover)),
                  Positioned(top: 0, right: 0, child: GestureDetector(
                    onTap: () => setState(() => _photos.remove(p)),
                    child: Container(decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle), child: Icon(Icons.close, size: 16, color: Colors.white)),
                  )),
                ])).toList()),
              ],
            ],
            if (!_editing && entry.photoPaths.isNotEmpty) ...[
              SizedBox(height: 16), PhotoGallery(photoPaths: entry.photoPaths),
            ],
            if (!_editing && entry.audioPath != null) ...[
              SizedBox(height: 8),
              Row(children: [AudioPlayerWidget(audioPath: entry.audioPath!), SizedBox(width: 8), Text('录音', style: TextStyle(color: AppColors.textSecondary, fontSize: 13))]),
            ],
            if (_editing) ...[
              SizedBox(height: 16),
              Container(
                decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.borderLight, width: 0.5)),
                padding: EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('标签', style: Theme.of(context).textTheme.labelSmall),
                  SizedBox(height: 8),
                  Wrap(spacing: 8, runSpacing: 4, children: [
                    ..._tags.map((tag) => Chip(
                      label: Text(tag, style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                      onDeleted: () => setState(() => _tags.remove(tag)),
                      deleteIconColor: AppColors.accent,
                      backgroundColor: AppColors.accentLight,
                      side: BorderSide(color: AppColors.accent.withValues(alpha: 0.4), width: 1),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    )),
                    ActionChip(
                      label: Text('+ 添加', style: TextStyle(fontSize: 12, color: AppColors.accent)),
                      onPressed: () => _showTagDialog(),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      side: BorderSide(color: AppColors.accent.withValues(alpha: 0.4), width: 1),
                    ),
                  ]),
                ]),
              ),
            ],
            if (!_editing && entry.tags.isNotEmpty) ...[
              SizedBox(height: 16),
              Wrap(spacing: 8, children: entry.tags.map((tag) => Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(16)),
                child: Text(tag, style: TextStyle(fontSize: 12, color: AppColors.accent)),
              )).toList()),
            ],
          ],
        ),
      ),
    );
  }

  void _showTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.card,
        title: Text('添加标签', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(controller: controller, autofocus: true, style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(hintText: '输入标签名', hintStyle: TextStyle(color: AppColors.textMuted))),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text('取消', style: TextStyle(color: AppColors.textMuted))),
          TextButton(onPressed: () {
            if (controller.text.isNotEmpty) setState(() => _tags.add(controller.text));
            Navigator.of(ctx).pop();
          }, child: Text('添加', style: TextStyle(color: AppColors.accent))),
        ],
      ),
    );
  }
}
