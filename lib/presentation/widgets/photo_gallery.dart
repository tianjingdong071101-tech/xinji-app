import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class PhotoGallery extends StatelessWidget {
  final List<String> photoPaths;
  final bool editable;

  const PhotoGallery({super.key, required this.photoPaths, this.editable = false});

  @override
  Widget build(BuildContext context) {
    if (photoPaths.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 80,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: 20),
            itemCount: photoPaths.length,
            separatorBuilder: (_, __) => SizedBox(width: 8),
            itemBuilder: (_, i) {
              final path = photoPaths[i];
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(path),
                  width: 80, height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 80, height: 80,
                    color: AppColors.cardLight,
                    child: Icon(Icons.broken_image, color: AppColors.textMuted),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
