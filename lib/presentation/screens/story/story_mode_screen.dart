import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/util/date_util.dart';
import '../../../domain/model/essay_entry.dart';
import '../../widgets/photo_gallery.dart';
import '../../widgets/audio_player.dart';

class StoryModeScreen extends ConsumerStatefulWidget {
  final DiaryEntry entry;
  final List<DiaryEntry> allEntries;

  const StoryModeScreen({
    super.key,
    required this.entry,
    required this.allEntries,
  });

  @override
  ConsumerState<StoryModeScreen> createState() => _StoryModeScreenState();
}

class _StoryModeScreenState extends ConsumerState<StoryModeScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.allEntries.indexWhere((e) => e.id == widget.entry.id);
    if (_currentIndex < 0) _currentIndex = 0;
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final entry = widget.allEntries[_currentIndex];
    final bgColor = entry.moodType.color.withValues(alpha: 0.1);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      color: bgColor,
      child: Scaffold(
        backgroundColor: bgColor,
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => context.pop(),
          ),
        ),
        body: PageView.builder(
          controller: _pageController,
          onPageChanged: (i) => setState(() => _currentIndex = i),
          itemCount: widget.allEntries.length,
          itemBuilder: (_, i) => _StoryPage(
            entry: widget.allEntries[i],
            totalCount: widget.allEntries.length,
            currentIndex: i,
          ),
        ),
      ),
    );
  }
}

class _StoryPage extends StatelessWidget {
  final DiaryEntry entry;
  final int totalCount;
  final int currentIndex;

  const _StoryPage({required this.entry, required this.totalCount, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final moodColor = entry.moodType.color;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${entry.createdAt.year}.${entry.createdAt.month.toString().padLeft(2, '0')}.${entry.createdAt.day.toString().padLeft(2, '0')}',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 28),
          ),
          const SizedBox(height: 2),
          Text(
            DateUtil.weekday(entry.createdAt),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(fontSize: 13),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: moodColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(entry.moodType.emoji, style: const TextStyle(fontSize: 16)),
                const SizedBox(width: 6),
                Text(
                  entry.moodType.label,
                  style: TextStyle(color: moodColor, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          if (entry.title != null && entry.title!.isNotEmpty) ...[
            Text(entry.title!, style: Theme.of(context).textTheme.headlineLarge),
            const SizedBox(height: 12),
          ],
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border(
                left: BorderSide(color: moodColor.withValues(alpha: 0.4), width: 4),
              ),
            ),
            child: Text(
              entry.content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.8),
            ),
          ),
          if (entry.photoPaths.isNotEmpty) ...[
            const SizedBox(height: 16),
            PhotoGallery(photoPaths: entry.photoPaths),
          ],
          if (entry.audioPath != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                AudioPlayerWidget(audioPath: entry.audioPath!),
                const SizedBox(width: 8),
                Text('录音', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              ],
            ),
          ],
          if (entry.tags.isNotEmpty) ...[
            const SizedBox(height: 20),
            Wrap(
              spacing: 8, runSpacing: 4,
              children: entry.tags.map((tag) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: moodColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(tag, style: TextStyle(fontSize: 12, color: moodColor)),
              )).toList(),
            ),
          ],
          const SizedBox(height: 32),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: Text(
                '${currentIndex + 1} / $totalCount',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
