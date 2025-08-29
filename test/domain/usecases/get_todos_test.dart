import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:arch/domain/entities/todo.dart';
import 'package:arch/domain/repositories/todo_repository.dart';
import 'package:arch/domain/usecases/get_todos.dart';

@GenerateMocks([TodoRepository])
import 'get_todos_test.mocks.dart';

void main() {
  late MockTodoRepository mockRepository;
  late GetTodos usecase;

  setUp(() {
    mockRepository = MockTodoRepository();
    usecase = GetTodos(mockRepository);
  });

  test('calls repository.getTodos and returns result', () async {
    final todos = [Todo(id: '1', title: 'Test', priority: TodoPriority.low)];
    when(mockRepository.getTodos()).thenAnswer((_) async => todos);
    final result = await usecase();
    expect(result, todos);
    verify(mockRepository.getTodos()).called(1);
  });

  test('propagates errors', () async {
    when(mockRepository.getTodos()).thenThrow(Exception('error'));
    await expectLater(usecase(), throwsException);
  });
}
