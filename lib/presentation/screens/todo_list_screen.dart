
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/todo.dart';
import '../providers/todo_provider.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';
class TodoListScreen extends ConsumerWidget {
  TodoListScreen({Key? key}) : super(key: key);

  void _showAddTodoDialog(BuildContext context, WidgetRef ref) {
    final TextEditingController _titleController = TextEditingController();
    final TextEditingController _categoryController = TextEditingController();
    final TextEditingController _notesController = TextEditingController();
    DateTime? _dueDate;
    TodoPriority _priority = TodoPriority.medium;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Add Todo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'Enter todo title'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TodoPriority>(
                            value: _priority,
                            decoration: const InputDecoration(labelText: 'Priority'),
                            items: TodoPriority.values.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _priority = val ?? TodoPriority.medium),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _categoryController,
                            decoration: const InputDecoration(labelText: 'Category'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => _dueDate = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Due Date'),
                              child: Text(_dueDate == null ? 'Select date' : DateFormat.yMMMd().format(_dueDate!)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.trim().isNotEmpty) {
                      final todo = Todo(
                        id: const Uuid().v4(),
                        title: _titleController.text.trim(),
                        dueDate: _dueDate,
                        priority: _priority,
                        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
                        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                      );
                      ref.read(todoListProvider.notifier).add(todo);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _addTodo(BuildContext context, WidgetRef ref, TextEditingController controller) {
    if (controller.text.trim().isNotEmpty) {
      final todo = Todo(
        id: const Uuid().v4(),
        title: controller.text.trim(),
      );
      ref.read(todoListProvider.notifier).add(todo);
      Navigator.of(context).pop();
    }
  }

  void _showEditTodoDialog(BuildContext context, WidgetRef ref, Todo todo) {
    final TextEditingController _titleController = TextEditingController(text: todo.title);
    final TextEditingController _categoryController = TextEditingController(text: todo.category ?? '');
    final TextEditingController _notesController = TextEditingController(text: todo.notes ?? '');
    DateTime? _dueDate = todo.dueDate;
    TodoPriority _priority = todo.priority;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Edit Todo'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _titleController,
                      autofocus: true,
                      decoration: const InputDecoration(hintText: 'Enter todo title'),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<TodoPriority>(
                            value: _priority,
                            decoration: const InputDecoration(labelText: 'Priority'),
                            items: TodoPriority.values.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _priority = val ?? TodoPriority.medium),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: _categoryController,
                            decoration: const InputDecoration(labelText: 'Category'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            borderRadius: BorderRadius.circular(8),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _dueDate ?? DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) setState(() => _dueDate = picked);
                            },
                            child: InputDecorator(
                              decoration: const InputDecoration(labelText: 'Due Date'),
                              child: Text(_dueDate == null ? 'Select date' : DateFormat.yMMMd().format(_dueDate!)),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _notesController,
                      decoration: const InputDecoration(labelText: 'Notes'),
                      minLines: 1,
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_titleController.text.trim().isNotEmpty) {
                      final updated = todo.copyWith(
                        title: _titleController.text.trim(),
                        dueDate: _dueDate,
                        priority: _priority,
                        category: _categoryController.text.trim().isEmpty ? null : _categoryController.text.trim(),
                        notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
                      );
                      ref.read(todoListProvider.notifier).update(updated);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(todoListProvider);
  final notifier = ref.read(todoListProvider.notifier);
  final theme = Theme.of(context);
  final statusOptions = ['All', 'Todo', 'Completed'];
  final statusFilter = state.statusFilter;
  final allCategories = state.allTodos.map((t) => t.category).whereType<String>().toSet().toList();
  List<Todo> allFiltered = state.filteredTodos();
  // Sort: incomplete (todo) first, then completed
  allFiltered.sort((a, b) {
    if (a.completed == b.completed) return 0;
    return a.completed ? 1 : -1;
  });
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search todos...',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (val) {
                print('[UI] Search changed: $val');
                notifier.setSearch(val);
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                PopupMenuButton<TodoPriority?>(
                  icon: const Icon(Icons.flag),
                  tooltip: 'Filter by Priority',
                  onOpened: () {
                    print('[UI] Priority filter popup opened');
                  },
                  onSelected: (priority) {
                    print('[UI] Priority filter: \u001b[1m${priority?.name ?? 'All'}\u001b[0m');
                    notifier.setPriority(priority);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<TodoPriority?>(
                      value: null,
                      child: const Text('All Priorities'),
                      onTap: () {
                        print('[UI] Priority filter: \\x1b[1mAll\\x1b[0m (onTap)');
                        notifier.setPriority(null);
                      },
                    ),
                    ...TodoPriority.values.map((p) => PopupMenuItem(
                      value: p,
                      child: Text(p.name[0].toUpperCase() + p.name.substring(1)),
                    )),
                  ],
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String?>(
                  icon: const Icon(Icons.label),
                  tooltip: 'Filter by Category',
                  onOpened: () {
                    print('[UI] Category filter popup opened');
                  },
                  onSelected: (cat) {
                    print('[UI] Category filter: \u001b[1m${cat ?? 'All'}\u001b[0m');
                    notifier.setCategory(cat);
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String?>(
                      value: null,
                      child: const Text('All Categories'),
                      onTap: () {
                        print('[UI] Category filter: \\x1b[1mAll\\x1b[0m (onTap)');
                        notifier.setCategory(null);
                      },
                    ),
                    ...allCategories.map((cat) => PopupMenuItem(
                      value: cat,
                      child: Text(cat),
                    )),
                  ],
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.checklist),
                  tooltip: 'Filter by Status',
                  initialValue: statusFilter,
                  onSelected: (status) {
                    print('[UI] Status filter: $status');
                    notifier.setStatusFilter(status);
                  },
                  itemBuilder: (context) => statusOptions
                      .map((s) => PopupMenuItem<String>(
                            value: s,
                            child: Text(s),
                          ))
                      .toList(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: allFiltered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: theme.colorScheme.primary.withOpacity(0.3)),
                          const SizedBox(height: 16),
                          Text('No todos found!', style: theme.textTheme.titleMedium?.copyWith(color: theme.disabledColor)),
                        ],
                      ),
                    )
                  : ListView.separated(
                      itemCount: allFiltered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final todo = allFiltered[index];
                        return Dismissible(
                          key: ValueKey(todo.id),
                          direction: DismissDirection.horizontal,
                          background: Container(
                            alignment: Alignment.centerLeft,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.green,
                            child: const Icon(Icons.check, color: Colors.white),
                          ),
                          secondaryBackground: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.red,
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                          confirmDismiss: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              // Left swipe: delete with confirmation
                              return await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Delete Task'),
                                  content: const Text('Are you sure you want to delete this task?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(true),
                                      child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                ),
                              ) ?? false;
                            } else if (direction == DismissDirection.startToEnd) {
                              // Right swipe: mark as complete (no confirmation)
                              if (!todo.completed) {
                                notifier.update(todo.copyWith(completed: true));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Task marked as complete')),
                                );
                              }
                              return false; // Don't dismiss from the list
                            }
                            return false;
                          },
                          onDismissed: (direction) async {
                            if (direction == DismissDirection.endToStart) {
                              await notifier.remove(todo.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Task deleted')),
                              );
                            }
                          },
                          child: Card(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            elevation: 2,
                            child: ListTile(
                              leading: Checkbox(
                                value: todo.completed,
                                shape: const CircleBorder(),
                                onChanged: (val) {
                                  notifier.update(
                                    todo.copyWith(completed: val ?? false),
                                  );
                                },
                              ),
                              title: Text(
                                todo.title,
                                style: TextStyle(
                                  decoration: todo.completed ? TextDecoration.lineThrough : null,
                                  color: todo.completed ? theme.disabledColor : null,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (todo.dueDate != null)
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16),
                                        const SizedBox(width: 4),
                                        Text(DateFormat.yMMMd().format(todo.dueDate!), style: const TextStyle(fontSize: 12)),
                                      ],
                                    ),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.flag,
                                        size: 16,
                                        color: todo.priority == TodoPriority.high
                                            ? Colors.red
                                            : todo.priority == TodoPriority.medium
                                                ? Colors.orange
                                                : Colors.green,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(todo.priority.name[0].toUpperCase() + todo.priority.name.substring(1), style: const TextStyle(fontSize: 12)),
                                      if (todo.category != null && todo.category!.isNotEmpty) ...[
                                        const SizedBox(width: 12),
                                        const Icon(Icons.label, size: 16),
                                        const SizedBox(width: 4),
                                        Text(todo.category!, style: const TextStyle(fontSize: 12)),
                                      ],
                                    ],
                                  ),
                                  if (todo.notes != null && todo.notes!.isNotEmpty)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4.0),
                                      child: Text(todo.notes!, style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                                    ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  _showEditTodoDialog(context, ref, todo);
                                },
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          print('[UI] Add Todo FAB pressed');
          _showAddTodoDialog(context, ref);
        },
        child: const Icon(Icons.add),
        shape: const CircleBorder(),
      ),
    );
  }
}
