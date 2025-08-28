import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:arch/domain/entities/todo.dart';
import 'package:arch/domain/repositories/todo_repository.dart';
import 'package:arch/domain/usecases/add_todo.dart';

@GenerateMocks([TodoRepository])
import 'add_todo_test.mocks.dart';

void main() {
  late MockTodoRepository mockRepository;
  late AddTodo usecase;

  setUp(() {
    mockRepository = MockTodoRepository();
    usecase = AddTodo(mockRepository);
  });

  test('calls repository.addTodo', () async {
    final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
    when(mockRepository.addTodo(todo)).thenAnswer((_) async {});
    await usecase(todo);
    verify(mockRepository.addTodo(todo)).called(1);
  });

  test('propagates errors', () async {
    final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
    when(mockRepository.addTodo(todo)).thenThrow(Exception('error'));
    await expectLater(usecase(todo), throwsException);
  });
}
