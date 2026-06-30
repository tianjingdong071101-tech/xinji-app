import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/model/mood_type.dart';

class MoodPicker extends StatefulWidget {
  final MoodType? selectedMood;
  final ValueChanged<MoodType> onMoodSelected;

  const MoodPicker({
    super.key,
    this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  State<MoodPicker> createState() => _MoodPickerState();
}

class _MoodPickerState extends State<MoodPicker>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  MoodType? _hoveredMood;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, _) {
        final pulse = _pulseController.value;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 10),
              child: Row(
                children: [
                  Text('此刻的心情',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          )),
                  const SizedBox(width: 8),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.accent
                          .withValues(alpha: 0.3 + pulse * 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: MoodType.values.map((mood) {
                final isSelected = mood == widget.selectedMood;
                final isHovered = mood == _hoveredMood;
                final mPulse = isSelected
                    ? 1.0 + pulse * 0.06
                    : 1.0;
                final borderRadius = isSelected ? 20.0 : 16.0;

                return Expanded(
                  child: GestureDetector(
                    onTap: () => widget.onMoodSelected(mood),
                    onTapDown: (_) => setState(() => _hoveredMood = mood),
                    onTapUp: (_) => setState(() => _hoveredMood = null),
                    onTapCancel: () => setState(() => _hoveredMood = null),
                    child: Transform.scale(
                      scale: mPulse,
                      alignment: Alignment.center,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? mood.color.withValues(alpha: 0.12)
                                : (isHovered
                                    ? AppColors.cardLight
                                    : Colors.transparent),
                            borderRadius: BorderRadius.circular(borderRadius),
                            border: Border.all(
                              color: isSelected
                                  ? mood.color.withValues(alpha: 0.6)
                                  : AppColors.borderLight,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                mood.emoji,
                                style: TextStyle(
                                  fontSize: isSelected ? 22 : 18,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                mood.label,
                                style: TextStyle(
                                  fontSize: isSelected ? 10 : 9,
                                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                                  color: isSelected ? mood.color : AppColors.textMuted,
                                  fontFamily: 'Epilogue',
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (isSelected)
                                Padding(
                                  padding: const EdgeInsets.only(top: 2),
                                  child: Container(
                                    width: 4,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: mood.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}
