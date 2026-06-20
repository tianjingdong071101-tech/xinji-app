import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/aurora_background.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AuroraBackground(
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Text('我的', style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                color: AppColors.neonCyan,
              )),
              const SizedBox(height: 24),
              Card(
                child: Column(
                  children: [
                    _MenuItem(icon: Icons.download_outlined, label: '导出数据', onTap: () {}),
                    const Divider(height: 1, color: AppColors.glassBorder, indent: 56),
                    _MenuItem(icon: Icons.notifications_outlined, label: '每日提醒', onTap: () {}),
                    const Divider(height: 1, color: AppColors.glassBorder, indent: 56),
                    _MenuItem(icon: Icons.info_outline, label: '关于心迹', onTap: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  '心迹 v1.0.0\n数据仅存储在本地',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textSoft.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.neonCyan),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSoft),
      onTap: onTap,
    );
  }
}
