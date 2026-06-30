import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class EssayAudioRecorder extends StatefulWidget {
  final ValueChanged<String?> onAudioSaved;
  const EssayAudioRecorder({super.key, required this.onAudioSaved});

  @override
  State<EssayAudioRecorder> createState() => _DiaryAudioRecorderState();
}

class _DiaryAudioRecorderState extends State<EssayAudioRecorder> {
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.mic, color: AppColors.textMuted),
      onPressed: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('录音功能将在后续版本开放')),
        );
      },
    );
  }
}
