import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/model/essay_entry.dart';
import '../../../../data/repository/essay_repository_impl.dart';
import '../../../../presentation/providers/essay_providers.dart';
import '../../../widgets/essay_card.dart';

class TimelineFlow extends ConsumerWidget {
  final List<DiaryEntry> entries;
  final void Function(DiaryEntry)? onEntryTap;

  const TimelineFlow({super.key, required this.entries, this.onEntryTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (entries.isEmpty) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20, 60, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('📝', style: TextStyle(fontSize: 48)),
            SizedBox(height: 16),
            Text('还没有随笔', style: TextStyle(color: AppColors.textSecondary)),
            SizedBox(height: 8),
            Text('点击下方按钮，记录今天的心情', style: TextStyle(color: AppColors.textMuted)),
          ],
        ),
      );
    }

    final segments = _segmentEntries(entries);
    return ListView.builder(
      padding: EdgeInsets.only(bottom: 80),
      itemCount: _totalItemCount(segments),
      itemBuilder: (_, i) => _buildItem(context, ref, segments, i),
    );
  }

  List<_Segment> _segmentEntries(List<DiaryEntry> all) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final monthStart = DateTime(today.year, today.month, 1);

    final Map<String, List<DiaryEntry>> groups = {};
    for (final entry in all) {
      final d = DateTime(entry.createdAt.year, entry.createdAt.month, entry.createdAt.day);
      String label;
      if (d.difference(today).inDays == 0) {
        label = '今天';
      } else if (d.difference(yesterday).inDays == 0) {
        label = '昨天';
      } else if (d.isAfter(weekStart.subtract(Duration(days: 1)))) {
        label = '本周';
      } else if (d.isAfter(monthStart.subtract(Duration(days: 1)))) {
        label = '本月';
      } else {
        label = '更早';
      }
      groups.putIfAbsent(label, () => []).add(entry);
    }

    final order = ['今天', '昨天', '本周', '本月', '更早'];
    return order.where((l) => groups.containsKey(l)).map((l) => _Segment(l, groups[l]!)).toList();
  }

  int _totalItemCount(List<_Segment> segments) {
    int count = 0;
    for (final seg in segments) {
      count += 1 + seg.entries.length;
    }
    return count;
  }

  Widget _buildItem(BuildContext context, WidgetRef ref, List<_Segment> segments, int index) {
    int offset = 0;
    for (final seg in segments) {
      if (index == offset) return _buildSegmentHeader(context, seg);
      final entryIdx = index - offset - 1;
      if (entryIdx < seg.entries.length) {
        final entry = seg.entries[entryIdx];
        return Dismissible(
          key: ValueKey('entry_${entry.id}'),
          direction: DismissDirection.endToStart,
          confirmDismiss: (_) async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                backgroundColor: AppColors.card,
                title: Text('删除随笔', style: TextStyle(color: AppColors.textPrimary)),
                content: Text('确定要删除这篇随笔吗？', style: TextStyle(color: AppColors.textSecondary)),
                actions: [
                  TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text('取消', style: TextStyle(color: AppColors.textMuted))),
                  TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('删除', style: TextStyle(color: AppColors.moodAnxious))),
                ],
              ),
            );
            if (confirmed == true) {
              await ref.read(diaryRepositoryProvider).deleteEntry(entry.id);
              ref.invalidate(diaryListProvider);
              return true;
            }
            return false;
          },
          background: Container(
            alignment: Alignment.centerRight,
            padding: EdgeInsets.only(right: 24),
            margin: EdgeInsets.fromLTRB(20, 6, 20, 6),
            decoration: BoxDecoration(
              color: AppColors.moodAnxious,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(Icons.delete_outline, color: Colors.white, size: 28),
          ),
          child: EssayCard(
            entry: entry,
            onTap: onEntryTap != null ? () => onEntryTap!(entry) : null,
          ),
        );
      }
      offset += 1 + seg.entries.length;
    }
    return SizedBox.shrink();
  }

  Widget _buildSegmentHeader(BuildContext context, _Segment seg) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 4),
      child: Row(
        children: [
          Text(seg.label, style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontSize: 13, color: AppColors.textSecondary, fontWeight: FontWeight.w600,
          )),
          SizedBox(width: 10),
          Expanded(child: Container(height: 1, color: AppColors.borderLight)),
        ],
      ),
    );
  }
}

class _Segment {
  final String label;
  final List<DiaryEntry> entries;
  const _Segment(this.label, this.entries);
}
