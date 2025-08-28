
  import 'package:hive/hive.dart';
  import '../../domain/entities/todo.dart';

/// Data source for Todo persistence using Hive.
///
/// - typeId for TodoAdapter: 0 (do not change once deployed)
/// - Field mapping:
///   0: id (String)
///   1: title (String)
///   2: completed (bool)
///   3: dueDate (DateTime?)
///   4: priority (TodoPriority)
///   5: category (String?)
///   6: notes (String?)
///
/// Best practices:
/// - Centralized adapter registration (call [registerAdapter] at app startup)
/// - Optional: Use [encryptionKey] for secure storage
class TodoLocalDataSource {
  static const String todoBoxName = 'todos';
  static const int todoTypeId = 0;
  late final Box<Todo> _box;

  /// Call this once at app startup, before any box is opened.
  /// Registers the [TodoAdapter] with Hive if not already registered.
  ///
  /// Call this once at app startup, before any box is opened.
  static void registerAdapter() {
    if (!Hive.isAdapterRegistered(todoTypeId)) {
      print('[TodoLocalDataSource] Registering TodoAdapter');
      Hive.registerAdapter(TodoAdapter());
    } else {
      print('[TodoLocalDataSource] TodoAdapter already registered');
    }
  }

  /// Initialize the box. Optionally provide an [encryptionKey] for secure storage.
  /// Initializes the Hive box for todos. Optionally provide an [encryptionKey] for secure storage.
  Future<void> init({List<int>? encryptionKey}) async {
    try {
      print('[TodoLocalDataSource] Opening Hive box: $todoBoxName');
      _box = await Hive.openBox<Todo>(
        todoBoxName,
        encryptionCipher: encryptionKey != null ? HiveAesCipher(encryptionKey) : null,
      );
      print('[TodoLocalDataSource] Box opened: ${_box.name}');
    } catch (e, st) {
      print('[TodoLocalDataSource] Error opening Hive box: $e\n$st');
      rethrow;
    }
  }

  /// Returns all todos from the box. Returns an empty list on error.
  List<Todo> getTodos() {
    try {
      final todos = _box.values.toList();
      print('[TodoLocalDataSource] getTodos: count = ${todos.length}');
      return todos;
    } catch (e, st) {
      print('[TodoLocalDataSource] Error reading todos: $e\n$st');
      return [];
    }
  }

  /// Adds a new todo to the box.
  Future<void> addTodo(Todo todo) async {
    try {
      print('[TodoLocalDataSource] addTodo: id=${todo.id}, title=${todo.title}');
      await _box.put(todo.id, todo);
    } catch (e, st) {
      print('[TodoLocalDataSource] Error adding todo: $e\n$st');
      rethrow;
    }
  }

  /// Updates an existing todo in the box.
  Future<void> updateTodo(Todo todo) async {
    try {
      print('[TodoLocalDataSource] updateTodo: id=${todo.id}, title=${todo.title}');
      await _box.put(todo.id, todo);
    } catch (e, st) {
      print('[TodoLocalDataSource] Error updating todo: $e\n$st');
      rethrow;
    }
  }

  /// Deletes a todo from the box by [id].
  Future<void> deleteTodo(String id) async {
    try {
      print('[TodoLocalDataSource] deleteTodo: id=$id');
      await _box.delete(id);
    } catch (e, st) {
      print('[TodoLocalDataSource] Error deleting todo: $e\n$st');
      rethrow;
    }
  }

  /// Call this at app shutdown to close the box and release resources.
  /// Closes the Hive box. Call this at app shutdown to release resources.
  Future<void> close() async {
    print('[TodoLocalDataSource] Closing Hive box: $todoBoxName');
    await _box.close();
    print('[TodoLocalDataSource] Box closed');
  }
}

// Hive TypeAdapter for Todo
/// Hive TypeAdapter for Todo
/// typeId must remain 0 for compatibility.
class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = TodoLocalDataSource.todoTypeId;

  @override
  Todo read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    final todo = Todo(
      id: fields[0] as String,
      title: fields[1] as String,
      completed: fields[2] as bool,
      dueDate: fields[3] as DateTime?,
      priority: TodoPriority.values[fields[4] as int],
      category: fields[5] as String?,
      notes: fields[6] as String?,
    );
    print('[TodoAdapter] read: id=${todo.id}, title=${todo.title}');
    return todo;
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    print('[TodoAdapter] write: id=${obj.id}, title=${obj.title}');
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.completed)
      ..writeByte(3)
      ..write(obj.dueDate)
      ..writeByte(4)
      ..write(obj.priority.index)
      ..writeByte(5)
      ..write(obj.category)
      ..writeByte(6)
      ..write(obj.notes);
  }
}
