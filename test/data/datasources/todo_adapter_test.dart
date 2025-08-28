import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:arch/data/datasources/todo_local_data_source.dart';
import 'package:arch/domain/entities/todo.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  group('TodoAdapter integration', () {
    const boxName = 'adapter_test_box';
    setUp(() async {
      Hive.init(Directory.systemTemp.path);
      if (!Hive.isAdapterRegistered(TodoLocalDataSource.todoTypeId)) {
        Hive.registerAdapter(TodoAdapter());
      }
      // Clean up box if exists
      final boxFile = File(p.join(Directory.systemTemp.path, '$boxName.hive'));
      if (boxFile.existsSync()) boxFile.deleteSync();
    });
    tearDown(() async {
      if (Hive.isBoxOpen(boxName)) {
        await Hive.box(boxName).close();
      }
      final boxFile = File(p.join(Directory.systemTemp.path, '$boxName.hive'));
      if (boxFile.existsSync()) boxFile.deleteSync();
    });

    test('can write and read Todo using Hive and TodoAdapter', () async {
      final box = await Hive.openBox<Todo>(boxName);
      final todo = Todo(
        id: 'id',
        title: 'title',
        completed: true,
        dueDate: DateTime(2025, 8, 17),
        priority: TodoPriority.high,
        category: 'cat',
        notes: 'notes',
      );
      await box.put(todo.id, todo);
      final read = box.get(todo.id);
      expect(read, isNotNull);
      expect(read!.id, todo.id);
      expect(read.title, todo.title);
      expect(read.completed, todo.completed);
      expect(read.dueDate, todo.dueDate);
      expect(read.priority, todo.priority);
      expect(read.category, todo.category);
      expect(read.notes, todo.notes);
      await box.close();
    });
  });

  group('TodoLocalDataSource.registerAdapter', () {
    test('registers adapter if not registered', () {
      // If not registered, register
      if (Hive.isAdapterRegistered(TodoLocalDataSource.todoTypeId)) {
        // Already registered, skip
        expect(Hive.isAdapterRegistered(TodoLocalDataSource.todoTypeId), true);
      } else {
        TodoLocalDataSource.registerAdapter();
        expect(Hive.isAdapterRegistered(TodoLocalDataSource.todoTypeId), true);
      }
    });

    test('does not register adapter if already registered', () {
      // Ensure registered
      if (!Hive.isAdapterRegistered(TodoLocalDataSource.todoTypeId)) {
        Hive.registerAdapter(TodoAdapter());
      }
      expect(Hive.isAdapterRegistered(TodoLocalDataSource.todoTypeId), true);
      // Should not throw
      TodoLocalDataSource.registerAdapter();
      expect(Hive.isAdapterRegistered(TodoLocalDataSource.todoTypeId), true);
    });
  });
}
