import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AudioPlayerWidget extends StatelessWidget {
  final String audioPath;
  const AudioPlayerWidget({super.key, required this.audioPath});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.mic, size: 20, color: AppColors.accent);
  }
}
