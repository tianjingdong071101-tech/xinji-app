import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../engine/export_engine.dart';
import '../../../engine/reminder_engine.dart' as eng;
import '../insights/widgets/todo_bottom_sheet.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final engine = ref.watch(eng.reminderEngineProvider);
    final reminderTime = engine.getReminderTimeString();
    final hasReminder = engine.hasReminder;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('我的',
                      style: Theme.of(context)
                          .textTheme
                          .displayLarge
                          ?.copyWith(color: AppColors.accent)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: hasReminder
                        ? AppColors.moodCalm.withValues(alpha: 0.1)
                        : AppColors.card,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        hasReminder ? Icons.notifications_active : Icons.notifications_none,
                        size: 12,
                        color: hasReminder ? AppColors.moodCalm : AppColors.textMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        hasReminder ? '提醒 $reminderTime' : '未设置提醒',
                        style: TextStyle(
                          fontSize: 11,
                          color: hasReminder ? AppColors.moodCalm : AppColors.textMuted,
                          fontWeight: FontWeight.w500,
                          fontFamily: 'Epilogue',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
                  _ReminderItem(
                    time: reminderTime,
                    hasReminder: hasReminder,
                    onSet: () => _setReminder(context, ref),
                    onCancel: () => _cancelReminder(context, ref),
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

  void _setReminder(BuildContext context, WidgetRef ref) async {
    final engine = ref.read(eng.reminderEngineProvider);
    final result = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 21, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.accent,
              onPrimary: Colors.white,
              surface: AppColors.card,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (result != null) {
      await engine.scheduleDaily(result.hour, result.minute);
      if (context.mounted) {
        _showSnackBar(
          context,
          '待办提醒已设置，将在 ${result.hour.toString().padLeft(2, '0')}:${result.minute.toString().padLeft(2, '0')} 提醒你',
        );
      }
    }
  }

  void _cancelReminder(BuildContext context, WidgetRef ref) async {
    final engine = ref.read(eng.reminderEngineProvider);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: AppColors.card,
        title: Text('取消提醒', style: TextStyle(color: AppColors.textPrimary)),
        content: Text('确定要关闭待办提醒吗？', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('保留', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('关闭', style: TextStyle(color: AppColors.moodAnxious)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await engine.cancel();
      if (context.mounted) {
        _showSnackBar(context, '待办提醒已关闭');
      }
    }
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

class _ReminderItem extends StatelessWidget {
  final String time;
  final bool hasReminder;
  final VoidCallback onSet;
  final VoidCallback onCancel;

  const _ReminderItem({
    required this.time,
    required this.hasReminder,
    required this.onSet,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        hasReminder ? Icons.notifications_active : Icons.notifications_outlined,
        color: hasReminder ? AppColors.moodCalm : AppColors.accent,
      ),
      title: Text('待办提醒', style: Theme.of(context).textTheme.bodyLarge),
      subtitle: Text(
        hasReminder ? '每天 $time 提醒查看待办' : '设置后每天定时提醒你处理待办',
        style: TextStyle(
          fontSize: 11,
          color: hasReminder ? AppColors.moodCalm : AppColors.textMuted,
        ),
      ),
      trailing: hasReminder
          ? GestureDetector(
              onTap: onCancel,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.moodAnxious.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.close, size: 12, color: AppColors.moodAnxious),
                    const SizedBox(width: 2),
                    Text('关闭',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppColors.moodAnxious,
                          fontWeight: FontWeight.w500,
                        )),
                  ],
                ),
              ),
            )
          : Icon(Icons.chevron_right, color: AppColors.textMuted),
      onTap: hasReminder ? null : onSet,
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
