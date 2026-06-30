import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/essay_providers.dart';
import '../../widgets/mood_picker.dart';
import '../../widgets/audio_recorder.dart' as ar;
import 'write_provider.dart';

class WriteScreen extends ConsumerWidget {
  const WriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writeDiaryProvider);
    final canSave = state.mood != null && state.content.isNotEmpty && !state.isSaving;

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        title: Text('写随笔', style: Theme.of(context).textTheme.headlineMedium),
        actions: [
          TextButton(
            onPressed: canSave
                ? () async {
                    final success = await ref.read(writeDiaryProvider.notifier).save();
                    if (success) ref.invalidate(diaryListProvider);
                    if (success && context.mounted) context.pop();
                  }
                : null,
            child: state.isSaving
                ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : Text('保存', style: TextStyle(
                    color: canSave ? AppColors.accent : AppColors.textMuted,
                  )),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (state.error != null)
              Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(state.error!, style: TextStyle(color: AppColors.accent)),
              ),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              padding: EdgeInsets.all(16),
              child: MoodPicker(
                selectedMood: state.mood,
                onMoodSelected: (mood) => ref.read(writeDiaryProvider.notifier).selectMood(mood),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              onChanged: (v) => ref.read(writeDiaryProvider.notifier).updateTitle(v),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 20),
              decoration: InputDecoration(
                hintText: '给今天的随笔起个标题（可选）',
                border: InputBorder.none,
                filled: false,
                hintStyle: TextStyle(color: AppColors.textMuted),
              ),
            ),
            SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: TextField(
                onChanged: (v) => ref.read(writeDiaryProvider.notifier).updateContent(v),
                maxLines: null,
                minLines: 12,
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: '今天发生了什么？你的感受是？',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(16),
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('附件', style: Theme.of(context).textTheme.labelSmall),
                      Spacer(),
                      ar.EssayAudioRecorder(
                        onAudioSaved: (path) => ref.read(writeDiaryProvider.notifier).setAudioPath(path),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  if (state.photoPaths.isNotEmpty)
                    Wrap(
                      spacing: 8, runSpacing: 8,
                      children: [
                        ...state.photoPaths.map((p) => Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(p), width: 64, height: 64, fit: BoxFit.cover),
                            ),
                            Positioned(
                              top: 0, right: 0,
                              child: GestureDetector(
                                onTap: () => ref.read(writeDiaryProvider.notifier).removePhoto(p),
                                child: Container(
                                  decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                  child: Icon(Icons.close, size: 16, color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        )),
                        GestureDetector(
                          onTap: () async {
                            final picker = ImagePicker();
                            final photo = await picker.pickImage(source: ImageSource.gallery);
                            if (photo != null) {
                              ref.read(writeDiaryProvider.notifier).addPhoto(photo.path);
                            }
                          },
                          child: Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.cardLight,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(Icons.add_photo_alternate, color: AppColors.textMuted),
                          ),
                        ),
                      ],
                    )
                  else
                    GestureDetector(
                      onTap: () async {
                        final picker = ImagePicker();
                        final photo = await picker.pickImage(source: ImageSource.gallery);
                        if (photo != null) {
                          ref.read(writeDiaryProvider.notifier).addPhoto(photo.path);
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.cardLight,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_photo_alternate, color: AppColors.textMuted),
                            SizedBox(width: 8),
                            Text('添加照片', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('标签', style: Theme.of(context).textTheme.labelSmall),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      ...state.tags.map((tag) => Chip(
                        label: Text(tag, style: TextStyle(fontSize: 12, color: AppColors.textPrimary)),
                        onDeleted: () => ref.read(writeDiaryProvider.notifier).removeTag(tag),
                        deleteIconColor: AppColors.accent,
                        backgroundColor: AppColors.accentLight,
                        side: BorderSide(color: AppColors.accent.withValues(alpha: 0.4), width: 1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      )),
                      ActionChip(
                        label: Text('+ 添加', style: TextStyle(fontSize: 12, color: AppColors.accent)),
                        onPressed: () => _showTagDialog(context, ref),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        side: BorderSide(color: AppColors.accent.withValues(alpha: 0.4), width: 1),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTagDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: AppColors.card,
        title: Text('添加标签', style: TextStyle(color: AppColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: '输入标签名',
            hintStyle: TextStyle(color: AppColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('取消', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(writeDiaryProvider.notifier).addTag(controller.text);
              }
              Navigator.of(ctx).pop();
            },
            child: Text('添加', style: TextStyle(color: AppColors.accent)),
          ),
        ],
      ),
    );
  }
}
