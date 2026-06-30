import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../domain/model/mood_type.dart';

class MoodStarDetail extends StatefulWidget {
  final MoodType mood;
  final int count;
  final double percentage;
  final VoidCallback onClose;

  const MoodStarDetail({
    super.key,
    required this.mood,
    required this.count,
    required this.percentage,
    required this.onClose,
  });

  @override
  State<MoodStarDetail> createState() => _MoodStarDetailState();
}

class _MoodStarDetailState extends State<MoodStarDetail>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnim = CurvedAnimation(
      parent: _controller,
      curve: const ElasticOutCurve(0.6),
    );
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0, 0.3)),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mood = widget.mood;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Opacity(
          opacity: _fadeAnim.value,
          child: Transform.scale(
            scale: _scaleAnim.value,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () {
                    _controller.reverse().then((_) => widget.onClose());
                  },
                  child: Container(
                    width: 300,
                    margin: const EdgeInsets.symmetric(horizontal: 40),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: mood.color.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildHeader(mood),
                        _buildBody(mood),
                        _buildBar(mood),
                        _buildFooter(mood),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(MoodType mood) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: mood.color.withValues(alpha: 0.15),
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: mood.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Center(
              child: Text(mood.emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mood.label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: mood.color,
                    fontFamily: 'Fraunces',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${widget.count} 次记录',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontFamily: 'Epilogue',
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              _controller.reverse().then((_) => widget.onClose());
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.cardLight,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.close, size: 16, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(MoodType mood) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: _InfoTile(
              icon: Icons.auto_awesome,
              label: '占比',
              value: '${(widget.percentage * 100).toStringAsFixed(0)}%',
              color: mood.color,
            ),
          ),
          Expanded(
            child: _InfoTile(
              icon: Icons.timeline,
              label: '频率',
              value: widget.count > 5 ? '频繁' : (widget.count > 2 ? '一般' : '较少'),
              color: mood.color,
            ),
          ),
          Expanded(
            child: _InfoTile(
              icon: Icons.wb_sunny_outlined,
              label: '色调',
              value: _moodTone(mood),
              color: mood.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(MoodType mood) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '情绪强度',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                  fontFamily: 'Epilogue',
                ),
              ),
              const Spacer(),
              Text(
                '${(widget.percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: mood.color,
                  fontFamily: 'Epilogue',
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              color: AppColors.cardLight,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: widget.percentage.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      colors: [
                        mood.color.withValues(alpha: 0.5),
                        mood.color,
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(MoodType mood) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 12, color: AppColors.textMuted),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              _moodDescription(mood),
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textMuted,
                fontFamily: 'Epilogue',
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _moodTone(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return '暖色';
      case MoodType.calm: return '中性';
      case MoodType.longing: return '暖灰';
      case MoodType.sad: return '冷灰';
      case MoodType.anxious: return '暖橙';
      case MoodType.hopeful: return '冷绿';
    }
  }

  String _moodDescription(MoodType mood) {
    switch (mood) {
      case MoodType.happy: return '快乐是内心最明亮的光芒，记录下来，让温暖延续。';
      case MoodType.calm: return '平静是心灵的港湾，在纷扰中守住一方安宁。';
      case MoodType.longing: return '思念是跨越时空的连线，每一次回忆都是重逢。';
      case MoodType.sad: return '忧伤也是生活的一部分，允许自己停下来感受。';
      case MoodType.anxious: return '焦虑是前行时的风声，听见它，但不必被它带走。';
      case MoodType.hopeful: return '期待是望向远方的目光，每一天都有新的可能。';
    }
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 18, color: color.withValues(alpha: 0.6)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
            fontFamily: 'Fraunces',
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: AppColors.textMuted,
            fontFamily: 'Epilogue',
          ),
        ),
      ],
    );
  }
}
