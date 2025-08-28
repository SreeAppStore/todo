
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:arch/data/repositories/todo_repository_impl.dart';
import 'package:arch/domain/entities/todo.dart';
import 'package:arch/data/datasources/todo_local_data_source.dart';

@GenerateMocks([TodoLocalDataSource])
import 'todo_repository_impl_test.mocks.dart';

void main() {
  late TodoRepositoryImpl repository;
  late MockTodoLocalDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockTodoLocalDataSource();
    when(mockDataSource.getTodos()).thenReturn([]); // Default stub for null safety
    repository = TodoRepositoryImpl(mockDataSource);
  });

  test('getTodos returns todos from data source', () async {
    final todos = [Todo(id: '1', title: 'Test', priority: TodoPriority.low)];
    when(mockDataSource.getTodos()).thenReturn(todos);
    final result = await repository.getTodos();
    expect(result, todos);
    verify(mockDataSource.getTodos()).called(1);
  });

  test('addTodo calls data source', () async {
    final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
    when(mockDataSource.addTodo(todo)).thenAnswer((_) async {});
    await repository.addTodo(todo);
    verify(mockDataSource.addTodo(todo)).called(1);
  });

  test('updateTodo calls data source', () async {
    final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
    when(mockDataSource.updateTodo(todo)).thenAnswer((_) async {});
    await repository.updateTodo(todo);
    verify(mockDataSource.updateTodo(todo)).called(1);
  });

  test('deleteTodo calls data source', () async {
    const id = '1';
    when(mockDataSource.deleteTodo(id)).thenAnswer((_) async {});
    await repository.deleteTodo(id);
    verify(mockDataSource.deleteTodo(id)).called(1);
  });

  test('getTodos propagates errors', () async {
    when(mockDataSource.getTodos()).thenThrow(Exception('error'));
    await expectLater(repository.getTodos(), throwsException);
  });

  test('addTodo propagates errors', () async {
    final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
    when(mockDataSource.addTodo(todo)).thenThrow(Exception('error'));
    await expectLater(repository.addTodo(todo), throwsException);
  });

  test('updateTodo propagates errors', () async {
    final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
    when(mockDataSource.updateTodo(todo)).thenThrow(Exception('error'));
    await expectLater(repository.updateTodo(todo), throwsException);
  });

  test('deleteTodo propagates errors', () async {
    const id = '1';
    when(mockDataSource.deleteTodo(id)).thenThrow(Exception('error'));
    await expectLater(repository.deleteTodo(id), throwsException);
  });
}
