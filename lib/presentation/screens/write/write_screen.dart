import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/mood_picker.dart';
import '../../widgets/aurora_background.dart';
import 'write_provider.dart';

final writeDiaryProvider = StateNotifierProvider<WriteDiaryNotifier, WriteDiaryState>((ref) {
  return WriteDiaryNotifier();
});

class WriteScreen extends ConsumerWidget {
  const WriteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(writeDiaryProvider);

    return AuroraBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: AppColors.textWhite),
            onPressed: () => context.pop(),
          ),
          title: Text('写日记', style: Theme.of(context).textTheme.headlineMedium),
          actions: [
            TextButton(
              onPressed: state.mood == null || state.content.isEmpty
                  ? null
                  : () {
                      ref.read(writeDiaryProvider.notifier).reset();
                      context.pop();
                    },
              child: Text('保存', style: TextStyle(
                color: state.mood == null || state.content.isEmpty
                    ? AppColors.textSoft
                    : AppColors.neonCyan,
              )),
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: MoodPicker(
                    selectedMood: state.mood,
                    onMoodSelected: (mood) => ref.read(writeDiaryProvider.notifier).selectMood(mood),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                onChanged: (v) => ref.read(writeDiaryProvider.notifier).updateTitle(v),
                style: Theme.of(context).textTheme.headlineMedium,
                decoration: InputDecoration(
                  hintText: '给今天的日记起个标题（可选）',
                  hintStyle: Theme.of(context).textTheme.bodyMedium,
                  border: InputBorder.none,
                  filled: false,
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: TextField(
                  onChanged: (v) => ref.read(writeDiaryProvider.notifier).updateContent(v),
                  maxLines: null,
                  minLines: 10,
                  style: Theme.of(context).textTheme.bodyLarge,
                  decoration: const InputDecoration(
                    hintText: '今天发生了什么？你的感受是？',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('标签', style: Theme.of(context).textTheme.labelSmall),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          ...state.tags.map((tag) => Chip(
                            label: Text(tag, style: const TextStyle(fontSize: 12, color: AppColors.textWhite)),
                            onDeleted: () => ref.read(writeDiaryProvider.notifier).removeTag(tag),
                            deleteIconColor: AppColors.neonCyan,
                            backgroundColor: AppColors.neonCyan.withValues(alpha: 0.15),
                          )),
                          ActionChip(
                            label: const Text('+ 添加', style: TextStyle(fontSize: 12, color: AppColors.neonCyan)),
                            onPressed: () => _showTagDialog(context, ref),
                            backgroundColor: AppColors.neonCyan.withValues(alpha: 0.08),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTagDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceDeep,
        title: const Text('添加标签', style: TextStyle(color: AppColors.textWhite)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.textWhite),
          decoration: const InputDecoration(
            hintText: '输入标签名',
            hintStyle: TextStyle(color: AppColors.textSoft),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消', style: TextStyle(color: AppColors.textSoft)),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref.read(writeDiaryProvider.notifier).addTag(controller.text);
              }
              Navigator.of(ctx).pop();
            },
            child: const Text('添加', style: TextStyle(color: AppColors.neonCyan)),
          ),
        ],
      ),
    );
  }
}
