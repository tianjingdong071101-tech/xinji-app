import 'dart:math';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class AuroraBackground extends StatelessWidget {
  final Widget child;

  const AuroraBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
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
            child: _GlowBall(
              color: AppColors.neonPurple.withValues(alpha: 0.15),
              size: 300,
            ),
          ),
          Positioned(
            bottom: -80,
            right: -40,
            child: _GlowBall(
              color: AppColors.neonCyan.withValues(alpha: 0.1),
              size: 250,
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            right: -60,
            child: _GlowBall(
              color: AppColors.moodHappy.withValues(alpha: 0.08),
              size: 200,
            ),
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
          colors: [color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
