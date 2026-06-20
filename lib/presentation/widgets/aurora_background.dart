import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AuroraBackground extends StatelessWidget {
  final Widget child;
  final Color? accentColor; // when set, glow balls tint toward this color

  const AuroraBackground({super.key, required this.child, this.accentColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.surfaceDark,
            AppColors.surfaceMid,
            AppColors.surfaceDeep,
            AppColors.surfaceDark,
          ],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ),
      ),
      child: Stack(
        children: [
          // Mesh gradient: three overlapping radial glows at different positions
          Positioned(
            top: -120,
            left: -80,
            child: _Aura(color: accentColor ?? AppColors.accentPurple, size: 340),
          ),
          Positioned(
            bottom: -100,
            right: -60,
            child: _Aura(color: accentColor ?? AppColors.accentCyan, size: 280),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.35,
            right: -40,
            child: _Aura(color: accentColor ?? AppColors.moodHappy, size: 220),
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.15,
            left: -50,
            child: _Aura(color: accentColor ?? AppColors.moodSad, size: 180),
          ),
          child,
        ],
      ),
    );
  }
}

class _Aura extends StatelessWidget {
  final Color color;
  final double size;

  const _Aura({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withValues(alpha: 0.10),
            color.withValues(alpha: 0.04),
            color.withValues(alpha: 0),
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }
}
