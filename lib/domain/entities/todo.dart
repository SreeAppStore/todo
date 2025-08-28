enum TodoPriority { low, medium, high }

class Todo {
  final String id;
  final String title;
  final bool completed;
  final DateTime? dueDate;
  final TodoPriority priority;
  final String? category;
  final String? notes;

  Todo({
    required this.id,
    required this.title,
    this.completed = false,
    this.dueDate,
    this.priority = TodoPriority.medium,
    this.category,
    this.notes,
  });

  Todo copyWith({
    String? id,
    String? title,
    bool? completed,
    DateTime? dueDate,
    TodoPriority? priority,
    String? category,
    String? notes,
  }) {
    return Todo(
      id: id ?? this.id,
      title: title ?? this.title,
      completed: completed ?? this.completed,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      category: category ?? this.category,
      notes: notes ?? this.notes,
    );
  }
}
