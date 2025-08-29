import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:arch/domain/entities/todo.dart';
import 'package:arch/domain/repositories/todo_repository.dart';
import 'package:arch/domain/usecases/update_todo.dart';

@GenerateMocks([TodoRepository])
import 'update_todo_test.mocks.dart';

void main() {
  late MockTodoRepository mockRepository;
  late UpdateTodo usecase;

  setUp(() {
    mockRepository = MockTodoRepository();
    usecase = UpdateTodo(mockRepository);
  });

  test('calls repository.updateTodo', () async {
    final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
    when(mockRepository.updateTodo(todo)).thenAnswer((_) async {});
    await usecase(todo);
    verify(mockRepository.updateTodo(todo)).called(1);
  });

  test('propagates errors', () async {
    final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
    when(mockRepository.updateTodo(todo)).thenThrow(Exception('error'));
    await expectLater(usecase(todo), throwsException);
  });
}
