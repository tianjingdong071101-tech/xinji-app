import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/repository/todo_repository_impl.dart';
import '../../../../domain/model/todo_item.dart';

class TodoBottomSheet extends ConsumerStatefulWidget {
  final DateTime date;

  const TodoBottomSheet({super.key, required this.date});

  @override
  ConsumerState<TodoBottomSheet> createState() => _TodoBottomSheetState();
}

class _TodoBottomSheetState extends ConsumerState<TodoBottomSheet> {
  late Future<List<TodoItem>> _todosFuture;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() {
    final repo = ref.read(todoRepositoryProvider);
    _todosFuture = repo.getTodosByDate(widget.date);
  }

  void _refresh() {
    setState(() => _loadTodos());
  }

  void _showAddDialog() {
    final titleCtl = TextEditingController();
    final descCtl = TextEditingController();
    var priority = TodoPriority.normal;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.card,
          title:
              Text('添加待办', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtl,
                autofocus: true,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '待办内容',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descCtl,
                maxLines: 3,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '描述（可选）',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('优先级',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  SizedBox(width: 12),
                  _PriorityChip(
                    label: '普通',
                    selected: priority == TodoPriority.normal,
                    onTap: () =>
                        setDialogState(() => priority = TodoPriority.normal),
                  ),
                  SizedBox(width: 8),
                  _PriorityChip(
                    label: '重要',
                    selected: priority == TodoPriority.important,
                    onTap: () =>
                        setDialogState(() => priority = TodoPriority.important),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('取消',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                if (titleCtl.text.trim().isEmpty) return;
                final repo = ref.read(todoRepositoryProvider);
                await repo.insertTodo(TodoItem(
                  id: 0,
                  title: titleCtl.text.trim(),
                  description: descCtl.text.trim().isEmpty
                      ? null
                      : descCtl.text.trim(),
                  completed: false,
                  priority: priority,
                  date: widget.date,
                  createdAt: DateTime.now(),
                ));
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                _refresh();
              },
              child:
                  Text('添加', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(TodoItem item) {
    final titleCtl = TextEditingController(text: item.title);
    final descCtl = TextEditingController(text: item.description ?? '');
    var priority = item.priority;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          backgroundColor: AppColors.card,
          title:
              Text('编辑待办', style: TextStyle(color: AppColors.textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleCtl,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '待办内容',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: descCtl,
                maxLines: 3,
                style: TextStyle(color: AppColors.textPrimary),
                decoration: InputDecoration(
                  hintText: '描述（可选）',
                  hintStyle: TextStyle(color: AppColors.textMuted),
                ),
              ),
              SizedBox(height: 12),
              Row(
                children: [
                  Text('优先级',
                      style: TextStyle(
                          color: AppColors.textSecondary, fontSize: 13)),
                  SizedBox(width: 12),
                  _PriorityChip(
                    label: '普通',
                    selected: priority == TodoPriority.normal,
                    onTap: () =>
                        setDialogState(() => priority = TodoPriority.normal),
                  ),
                  SizedBox(width: 8),
                  _PriorityChip(
                    label: '重要',
                    selected: priority == TodoPriority.important,
                    onTap: () =>
                        setDialogState(() => priority = TodoPriority.important),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('取消',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                if (titleCtl.text.trim().isEmpty) return;
                final repo = ref.read(todoRepositoryProvider);
                await repo.updateTodo(item.copyWith(
                  title: titleCtl.text.trim(),
                  description: descCtl.text.trim().isEmpty
                      ? null
                      : descCtl.text.trim(),
                  priority: priority,
                ));
                if (!ctx.mounted) return;
                Navigator.of(ctx).pop();
                _refresh();
              },
              child:
                  Text('保存', style: TextStyle(color: AppColors.accent)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 16),
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.6),
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
          SizedBox(height: 16),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  '${widget.date.month}月${widget.date.day}日 待办',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                Spacer(),
                GestureDetector(
                  onTap: _showAddDialog,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('新建',
                            style:
                                TextStyle(fontSize: 12, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 12),
          Flexible(
            child: FutureBuilder<List<TodoItem>>(
              future: _todosFuture,
              builder: (_, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                          color: AppColors.accent));
                }
                final items = snap.data ?? [];
                if (items.isEmpty) {
                  return Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Text('📝', style: TextStyle(fontSize: 32)),
                        SizedBox(height: 8),
                        Text('暂无待办',
                            style: TextStyle(color: AppColors.textMuted)),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: EdgeInsets.only(bottom: 20),
                  itemCount: items.length,
                  itemBuilder: (_, i) => _TodoTile(
                    item: items[i],
                    onToggle: () async {
                      final repo = ref.read(todoRepositoryProvider);
                      await repo.toggleTodo(
                          items[i].id, !items[i].completed);
                      _refresh();
                    },
                    onEdit: () => _showEditDialog(items[i]),
                    onDelete: () async {
                      final repo = ref.read(todoRepositoryProvider);
                      await repo.deleteTodo(items[i].id);
                      _refresh();
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _PriorityChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.accent.withValues(alpha: 0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.borderLight,
            width: 1,
          ),
        ),
        child: Text(label,
            style: TextStyle(
              fontSize: 12,
              color:
                  selected ? AppColors.accent : AppColors.textSecondary,
              fontWeight:
                  selected ? FontWeight.w600 : FontWeight.w400,
            )),
      ),
    );
  }
}

class _TodoTile extends StatelessWidget {
  final TodoItem item;
  final VoidCallback onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TodoTile({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.cardLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: AppColors.borderLight, width: 0.5),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onToggle,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: item.completed
                      ? AppColors.moodCalm
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: item.completed
                        ? AppColors.moodCalm
                        : AppColors.textMuted,
                    width: 1.5,
                  ),
                ),
                child: item.completed
                    ? Icon(Icons.check, size: 14, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (item.priority == TodoPriority.important)
                        Container(
                          margin: EdgeInsets.only(right: 6),
                          padding: EdgeInsets.symmetric(
                              horizontal: 6, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppColors.moodAnxious
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text('重要',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.moodAnxious,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      Expanded(
                        child: Text(
                          item.title,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                decoration: item.completed
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: item.completed
                                    ? AppColors.textMuted
                                    : AppColors.textPrimary,
                              ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (item.description != null &&
                      item.description!.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Text(
                        item.description!,
                        style: Theme.of(context).textTheme.labelSmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
              ),
            ),
            GestureDetector(
              onTap: onDelete,
              child: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.delete_outline,
                    size: 18, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
