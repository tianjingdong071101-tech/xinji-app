import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class StarBackground extends StatelessWidget {
  final Widget child;

  const StarBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _StarDustPainter(),
          ),
        ),
        child,
      ],
    );
  }
}

class _StarDustPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(1729);
    final dustPaint = Paint()
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 80; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final s = rng.nextDouble() * 1.8 + 0.4;
      final a = rng.nextDouble() * 0.12 + 0.02;
      dustPaint.color = AppColors.accent.withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), s, dustPaint);
    }

    for (int i = 0; i < 30; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final s = rng.nextDouble() * 1.2 + 0.3;
      final a = rng.nextDouble() * 0.08 + 0.01;
      dustPaint.color = AppColors.sage.withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), s, dustPaint);
    }

    final grainPaint = Paint()
      ..color = AppColors.textPrimary.withValues(alpha: 0.02);
    for (int i = 0; i < 200; i++) {
      final x = rng.nextDouble() * size.width;
      final y = rng.nextDouble() * size.height;
      final s = rng.nextDouble() * 0.6 + 0.2;
      canvas.drawCircle(Offset(x, y), s, grainPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}

class ConstellationDivider extends StatelessWidget {
  final Color? color;

  const ConstellationDivider({super.key, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.borderLight;
    return Row(
      children: [
        Text('\u22C5', style: TextStyle(color: c.withValues(alpha: 0.3), fontSize: 10)),
        const SizedBox(width: 4),
        Expanded(child: Container(height: 0.5, color: c.withValues(alpha: 0.2))),
        const SizedBox(width: 4),
        Text('\u22C5', style: TextStyle(color: c.withValues(alpha: 0.3), fontSize: 10)),
      ],
    );
  }
}

class PulseDot extends StatelessWidget {
  final Color color;
  final double size;
  final bool glowing;

  const PulseDot({
    super.key,
    required this.color,
    this.size = 6,
    this.glowing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: size,
                  spreadRadius: size * 0.3,
                ),
              ]
            : null,
      ),
    );
  }
}

class OrganicArcPainter extends CustomPainter {
  final List<Color> colors;
  final double progress;

  OrganicArcPainter({required this.colors, this.progress = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    if (colors.isEmpty) return;
    final center = Offset(size.width / 2, size.height);
    final r = size.height * 0.8;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    for (int i = 0; i < colors.length; i++) {
      final startAngle = pi + 0.3 + i * 0.15;
      final sweepAngle = (pi - 0.6 - i * 0.15 * colors.length) * progress;
      paint.color = colors[i].withValues(alpha: 0.15);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r - i * 8),
        startAngle,
        sweepAngle.clamp(0.0, pi),
        false,
        paint..strokeWidth = 1.0 + (colors.length - i) * 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant OrganicArcPainter old) =>
      old.progress != progress || old.colors != colors;
}
