import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/util/date_util.dart';
import '../../domain/model/essay_entry.dart';

class EssayCard extends StatelessWidget {
  final DiaryEntry entry;
  final VoidCallback? onTap;
  final bool showDate;
  final List<String>? highlightTerms;

  const EssayCard({super.key, required this.entry, this.onTap, this.showDate = true, this.highlightTerms});

  @override
  Widget build(BuildContext context) {
    final moodColor = entry.moodType.color;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.fromLTRB(20, 6, 20, 6),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.borderLight, width: 0.5),
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 6,
                decoration: BoxDecoration(
                  color: moodColor,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 16, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (showDate)
                            Container(
                              padding: EdgeInsets.only(right: 12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                    Text(
                      '${entry.createdAt.day}',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                        fontSize: 22, height: 1.1, fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      DateUtil.weekday(entry.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontSize: 10, height: 1.1,
                      ),
                    ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      entry.moodType.emoji,
                                      style: TextStyle(fontSize: 13),
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      entry.moodType.label,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: moodColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (entry.title != null && entry.title!.isNotEmpty)
                                  Padding(
                                    padding: EdgeInsets.only(top: 2),
                                    child: Text(
                                      entry.title!,
                                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        fontSize: 16,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: highlightTerms != null && highlightTerms!.isNotEmpty
                                      ? _HighlightedText(text: entry.content, terms: highlightTerms!, style: Theme.of(context).textTheme.bodyMedium)
                                      : Text(
                                          entry.content,
                                          style: Theme.of(context).textTheme.bodyMedium,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                ),
                                if (entry.tags.isNotEmpty) ...[
                                  SizedBox(height: 8),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: entry.tags.map((tag) => TagChip(label: tag, color: moodColor)).toList(),
                                  ),
                                ],
                              ],
                            ),
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
}

class TagChip extends StatelessWidget {
  final String label;
  final Color color;
  const TagChip({super.key, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String text;
  final List<String> terms;
  final TextStyle? style;

  const _HighlightedText({required this.text, required this.terms, this.style});

  @override
  Widget build(BuildContext context) {
    if (terms.isEmpty) return Text(text, style: style, maxLines: 2, overflow: TextOverflow.ellipsis);

    final lowerText = text.toLowerCase();
    final spans = <TextSpan>[];
    int lastEnd = 0;

    for (final term in terms) {
      final lowerTerm = term.toLowerCase();
      int start = lowerText.indexOf(lowerTerm, lastEnd);
      if (start < 0) continue;
      if (start > lastEnd) {
        spans.add(TextSpan(text: text.substring(lastEnd, start)));
      }
      spans.add(TextSpan(
        text: text.substring(start, start + term.length),
        style: TextStyle(backgroundColor: AppColors.accentLight),
      ));
      lastEnd = start + term.length;
    }
    if (lastEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastEnd)));
    }

    return Text.rich(
      TextSpan(style: style, children: spans),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
