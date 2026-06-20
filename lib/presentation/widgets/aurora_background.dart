import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AuroraBackground extends StatelessWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundDark,
            AppColors.backgroundDeep,
            AppColors.backgroundDark,
          ],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -100,
            left: -50,
            child: _GlowBall(color: AppColors.neonPurple, size: 300),
          ),
          Positioned(
            bottom: -80,
            right: -40,
            child: _GlowBall(color: AppColors.neonCyan, size: 250),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -60,
            child: _GlowBall(color: AppColors.moodHappy, size: 200),
          ),
          child,
        ],
      ),
    );
  }
}

class _GlowBall extends StatelessWidget {
  final Color color;
  final double size;

  const _GlowBall({required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: 0.12), color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
