import 'dart:math';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/model/mood_type.dart';
import 'mood_star_detail.dart';

class MoodStarChart extends StatefulWidget {
  final Map<MoodType, int> distribution;

  const MoodStarChart({super.key, required this.distribution});

  @override
  State<MoodStarChart> createState() => _MoodStarChartState();
}

class _MoodStarChartState extends State<MoodStarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _breathController;
  MoodType? _highlightedMood;

  final Map<MoodType, Offset> _nodePositions = {};
  final Set<MoodType> _pressedNodes = {};

  @override
  void initState() {
    super.initState();
    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _breathController.dispose();
    super.dispose();
  }

  void _onNodeTap(MoodType mood, Offset globalPosition) {
    setState(() => _highlightedMood = mood);
    final total = widget.distribution.values.fold(0, (a, b) => a + b);
    final count = widget.distribution[mood] ?? 0;
    final double pct = total > 0 ? count / total : 0;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      elevation: 0,
      barrierColor: AppColors.textPrimary.withValues(alpha: 0.3),
      builder: (_) => MoodStarDetail(
        mood: mood,
        count: count,
        percentage: pct,
        onClose: () {
          setState(() => _highlightedMood = null);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasData =
        widget.distribution.values.any((v) => v > 0);
    if (!hasData) {
      return SizedBox(
        height: 240,
        child: Center(
          child: Text('暂无数据',
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _breathController,
      builder: (context, _) {
        final breath = _breathController.value;
        return SizedBox(
          height: 280,
          child: GestureDetector(
            onTapDown: (details) {
              final hit = _hitTest(details.localPosition);
              if (hit != null) {
                setState(() => _pressedNodes.add(hit));
              }
            },
            onTapUp: (details) {
              final hit = _hitTest(details.localPosition);
              if (hit != null) {
                final box = context.findRenderObject() as RenderBox;
                final global = box.localToGlobal(details.localPosition);
                _onNodeTap(hit, global);
              }
              setState(() => _pressedNodes.clear());
            },
            onTapCancel: () {
              setState(() => _pressedNodes.clear());
            },
            child: CustomPaint(
              size: const Size(double.infinity, 280),
              painter: _ConstellationPainter(
                distribution: widget.distribution,
                breath: breath,
                highlightedMood: _highlightedMood,
                pressedNodes: _pressedNodes,
              ),
            ),
          ),
        );
      },
    );
  }

  MoodType? _hitTest(Offset point) {
    _computePositions(140, 140, 120);
    for (final entry in _nodePositions.entries) {
      if ((point - entry.value).distance < 32) return entry.key;
    }
    return null;
  }

  void _computePositions(double cx, double cy, double r) {
    if (_nodePositions.isNotEmpty) return;
    final radius = r * 0.72;
    const angles = <MoodType, double>{
      MoodType.happy: -pi / 2,
      MoodType.calm: pi / 6,
      MoodType.hopeful: -pi / 6,
      MoodType.longing: 5 * pi / 6,
      MoodType.sad: 7 * pi / 6,
      MoodType.anxious: pi / 2,
    };
    for (final entry in angles.entries) {
      _nodePositions[entry.key] = Offset(
        cx + cos(entry.value) * radius,
        cy + sin(entry.value) * radius,
      );
    }
  }
}

class _ConstellationPainter extends CustomPainter {
  final Map<MoodType, int> distribution;
  final double breath;
  final MoodType? highlightedMood;
  final Set<MoodType> pressedNodes;

  _ConstellationPainter({
    required this.distribution,
    required this.breath,
    this.highlightedMood,
    this.pressedNodes = const {},
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final maxR = min(size.width, size.height) / 2 - 20;
    final maxCount = distribution.values
        .reduce(max)
        .toDouble();

    final positions = _computePositions(cx, cy, maxR);
    final activeEntries =
        distribution.entries.where((e) => e.value > 0).toList();
    if (activeEntries.isEmpty) return;

    _drawHalo(canvas, cx, cy, size);
    _drawConnections(canvas, positions, activeEntries, cx, cy, maxR);
    _drawNodes(canvas, positions, activeEntries, maxCount);
  }

  void _drawHalo(Canvas canvas, double cx, double cy, Size size) {
    final haloPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment(cx / size.width - 0.5, cy / size.height - 0.5),
        radius: 0.6,
        colors: [
          AppColors.accent.withValues(alpha: 0.04),
          AppColors.accent.withValues(alpha: 0.01),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawCircle(Offset(cx, cy), size.width * 0.45, haloPaint);
  }

  void _drawConnections(
    Canvas canvas,
    Map<MoodType, Offset> positions,
    List<MapEntry<MoodType, int>> active,
    double cx,
    double cy,
    double maxR,
  ) {
    for (int i = 0; i < active.length; i++) {
      for (int j = i + 1; j < active.length; j++) {
        final a = active[i];
        final b = active[j];
        final from = positions[a.key]!;
        final to = positions[b.key]!;
        final mid = Offset((from.dx + to.dx) / 2, (from.dy + to.dy) / 2);
        final dx = to.dx - from.dx;
        final dy = to.dy - from.dy;
        final dist = sqrt(dx * dx + dy * dy);
        final pull = dist * 0.2;
        final nx = -dy / dist;
        final ny = dx / dist;
        final cp = Offset(
          mid.dx + nx * pull * sin(breath * pi * 0.3 + 0.5),
          mid.dy + ny * pull * cos(breath * pi * 0.3 + 0.8),
        );

        final connectionPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8 + breath * 0.4
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.8);

        final path = Path()
          ..moveTo(from.dx, from.dy)
          ..quadraticBezierTo(cp.dx, cp.dy, to.dx, to.dy);

        connectionPaint.color = AppColors.textMuted.withValues(alpha: 0.12);
        connectionPaint.maskFilter = null;
        canvas.drawPath(path, connectionPaint);

        final glowPaint = Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
        glowPaint.color = AppColors.accent.withValues(alpha: 0.04 + breath * 0.03);
        canvas.drawPath(path, glowPaint);
      }
    }
  }

  void _drawNodes(
    Canvas canvas,
    Map<MoodType, Offset> positions,
    List<MapEntry<MoodType, int>> active,
    double maxCount,
  ) {
    for (final entry in active) {
      final mood = entry.key;
      final pos = positions[mood]!;
      final count = entry.value.toDouble();
      final baseRadius = 14.0 + (count / maxCount) * 26;
      final pulse = mood == highlightedMood ? 1.0 + breath * 0.12 : 1.0 + breath * 0.04;
      final pressed = pressedNodes.contains(mood);
      final r = baseRadius * pulse * (pressed ? 0.92 : 1.0);
      final isDominant = count >= maxCount;

      _drawNodeGlow(canvas, pos, r, mood);

      final fillPaint = Paint()
        ..color = mood.color.withValues(alpha: pressed ? 0.25 : 0.15);
      final borderPaint = Paint()
        ..color = mood.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = isDominant ? 2.0 : 1.2;

      final nodePath = _organicCirclePath(pos, r);
      canvas.drawPath(nodePath, fillPaint);
      canvas.drawPath(nodePath, borderPaint);

      final emojiSize = 14.0 + (count / maxCount) * 8;
      final ep = TextPainter(
        text: TextSpan(
          text: mood.emoji,
          style: TextStyle(fontSize: emojiSize),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      ep.paint(
        canvas,
        Offset(pos.dx - ep.width / 2, pos.dy - ep.height / 2),
      );

      final labelY = pos.dy + r + 6;
      final labelPainter = TextPainter(
        text: TextSpan(
          text: '${mood.label} $count',
          style: TextStyle(
            fontSize: 10,
            color: mood.color,
            fontWeight: FontWeight.w600,
            fontFamily: 'Epilogue',
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      labelPainter.paint(
        canvas,
        Offset(pos.dx - labelPainter.width / 2, labelY),
      );

      if (isDominant) {
        final domLabel = TextPainter(
          text: TextSpan(
            text: '主导',
            style: TextStyle(
              fontSize: 8,
              color: mood.color.withValues(alpha: 0.7),
              fontWeight: FontWeight.w500,
              fontFamily: 'Epilogue',
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();
        domLabel.paint(
          canvas,
          Offset(pos.dx - domLabel.width / 2, labelY + 14),
        );
      }
    }
  }

  void _drawNodeGlow(Canvas canvas, Offset pos, double r, MoodType mood) {
    if (mood != highlightedMood) return;
    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          mood.color.withValues(alpha: 0.25),
          mood.color.withValues(alpha: 0.08),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: pos, radius: r * 2.2));
    canvas.drawCircle(pos, r * 2.2, glowPaint);
  }

  Path _organicCirclePath(Offset center, double r) {
    final path = Path();
    final steps = 16;
    final seed = center.dx * 0.01 + center.dy * 0.02;
    for (int i = 0; i <= steps; i++) {
      final angle = 2 * pi * i / steps;
      final wobble = sin(angle * 3 + seed) * 0.06 + cos(angle * 5 + seed * 2) * 0.04;
      final rr = r * (1.0 + wobble);
      final x = center.dx + cos(angle) * rr;
      final y = center.dy + sin(angle) * rr;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        final prevAngle = 2 * pi * (i - 1) / steps;
        final prevWobble = sin(prevAngle * 3 + seed) * 0.06 + cos(prevAngle * 5 + seed * 2) * 0.04;
        final prevR = r * (1.0 + prevWobble);
        final prevX = center.dx + cos(prevAngle) * prevR;
        final prevY = center.dy + sin(prevAngle) * prevR;
        final cpx = (prevX + x) / 2;
        final cpy = (prevY + y) / 2;
        path.quadraticBezierTo(cpx, cpy, x, y);
      }
    }
    path.close();
    return path;
  }

  Map<MoodType, Offset> _computePositions(double cx, double cy, double r) {
    final map = <MoodType, Offset>{};
    final radius = r * 0.72;
    const angles = <MoodType, double>{
      MoodType.happy: -pi / 2,
      MoodType.calm: pi / 6,
      MoodType.hopeful: -pi / 6,
      MoodType.longing: 5 * pi / 6,
      MoodType.sad: 7 * pi / 6,
      MoodType.anxious: pi / 2,
    };
    for (final entry in angles.entries) {
      map[entry.key] = Offset(
        cx + cos(entry.value) * radius,
        cy + sin(entry.value) * radius,
      );
    }
    return map;
  }

  @override
  bool shouldRepaint(covariant _ConstellationPainter old) =>
      old.distribution != distribution ||
      old.breath != breath ||
      old.highlightedMood != highlightedMood ||
      old.pressedNodes != pressedNodes;
}
