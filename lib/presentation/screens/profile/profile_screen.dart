import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../engine/export_engine.dart';
import '../insights/widgets/todo_bottom_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 32),
            Text('我的',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge
                    ?.copyWith(color: AppColors.accent)),
            const SizedBox(height: 24),
            Container(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderLight, width: 0.5),
              ),
              child: Column(
                children: [
                  _MenuItem(
                    icon: Icons.checklist_rtl,
                    label: '待办管理',
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
                        builder: (_) => TodoBottomSheet(date: DateTime.now()),
                      );
                    },
                  ),
                  _MenuDivider(),
                  _MenuItem(
                    icon: Icons.download_outlined,
                    label: '导出数据',
                    onTap: () => _showExportOptions(context, ref),
                  ),
                  _MenuDivider(),
                  _MenuItem(
                    icon: Icons.info_outline,
                    label: '关于心迹',
                    onTap: () => _showAboutDialog(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Text(
              '心迹 v1.0.0\n数据仅存储在本地',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showExportOptions(BuildContext context, WidgetRef ref) {
    final engine = ref.read(exportEngineProvider);
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textMuted.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text('导出数据', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: Icon(Icons.code, color: AppColors.accent),
              title: Text('导出为 JSON'),
              subtitle: Text('包含全部随笔、标签和元数据',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onTap: () async {
                await engine.export(ExportFormat.json);
                if (ctx.mounted) Navigator.of(ctx).pop();
                _showSnackBar(context, '已导出为 JSON');
              },
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Icon(Icons.table_chart, color: AppColors.accent),
              title: Text('导出为 CSV'),
              subtitle: Text('可用电子表格软件打开',
                  style: TextStyle(fontSize: 12, color: AppColors.textMuted)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              onTap: () async {
                await engine.export(ExportFormat.csv);
                if (ctx.mounted) Navigator.of(ctx).pop();
                _showSnackBar(context, '已导出为 CSV');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.card,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.card,
        title: Text('关于心迹', style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          '心迹 v1.0.0\n\n一款以情绪追踪为核心的随笔 App。\n数据仅存储在本地，不会上传到云端。',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('关闭', style: TextStyle(color: AppColors.accent)),
          ),
        ],
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
      leading: Icon(icon, color: AppColors.accent),
      title: Text(label, style: Theme.of(context).textTheme.bodyLarge),
      trailing: Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Divider(height: 1, color: AppColors.borderLight, indent: 56);
  }
}
