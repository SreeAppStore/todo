
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:arch/data/datasources/todo_local_data_source.dart';
import 'package:arch/domain/entities/todo.dart';
import 'dart:io';
import 'package:path/path.dart' as p;

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = Directory.systemTemp.createTempSync();
    return dir.path;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();

  late TodoLocalDataSource dataSource;
  late String testBoxPath;

  test('init rethrows on Hive error', () async {
    // Simulate error by passing an invalid encryption key (wrong length)
    TodoLocalDataSource.registerAdapter();
    final ds = TodoLocalDataSource();
    // HiveAesCipher expects a 32-byte key, so passing a short key will throw
    expect(() async => await ds.init(encryptionKey: [1, 2, 3]), throwsA(anything));
  });

  setUp(() async {
    // Initialize Hive with a temp directory for tests
    Hive.init(Directory.systemTemp.path);
    TodoLocalDataSource.registerAdapter();
    dataSource = TodoLocalDataSource();
    await dataSource.init();
    testBoxPath = p.join(Directory.systemTemp.path, 'todos.hive');
  });

  tearDown(() async {
    await dataSource.close();
    final file = File(testBoxPath);
    if (file.existsSync()) file.deleteSync();
  });

  test('add, get, update, delete todo', () async {
    final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
    await dataSource.addTodo(todo);
    var todos = dataSource.getTodos();
    expect(todos.length, 1);
    expect(todos.first.title, 'Test');

    final updated = todo.copyWith(title: 'Updated', completed: true);
    await dataSource.updateTodo(updated);
    todos = dataSource.getTodos();
    expect(todos.first.title, 'Updated');
    expect(todos.first.completed, true);

    await dataSource.deleteTodo(todo.id);
    todos = dataSource.getTodos();
    expect(todos, isEmpty);
  });

  test('handles empty box gracefully', () async {
    final todos = dataSource.getTodos();
    expect(todos, isEmpty);
  });

  test('persists multiple todos', () async {
    final t1 = Todo(id: '1', title: 'A', priority: TodoPriority.low);
    final t2 = Todo(id: '2', title: 'B', priority: TodoPriority.high);
    await dataSource.addTodo(t1);
    await dataSource.addTodo(t2);
    final todos = dataSource.getTodos();
    expect(todos.length, 2);
    expect(todos.any((t) => t.title == 'A'), true);
    expect(todos.any((t) => t.title == 'B'), true);
  });

  group('error handling', () {
  // Removed invalid encryptionKey test (type error)

    test('getTodos returns [] on error', () async {
      // Simulate error by closing the box first
      await dataSource.close();
      final todos = dataSource.getTodos();
      expect(todos, isEmpty);
    });

    test('addTodo rethrows on error', () async {
      await dataSource.close();
      final todo = Todo(id: 'err', title: 'err', priority: TodoPriority.low);
      expect(() => dataSource.addTodo(todo), throwsA(anything));
    });

    test('updateTodo rethrows on error', () async {
      await dataSource.close();
      final todo = Todo(id: 'err', title: 'err', priority: TodoPriority.low);
      expect(() => dataSource.updateTodo(todo), throwsA(anything));
    });

    test('deleteTodo rethrows on error', () async {
      await dataSource.close();
      expect(() => dataSource.deleteTodo('err'), throwsA(anything));
    });
  });
}
