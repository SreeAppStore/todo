import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:arch/domain/repositories/todo_repository.dart';
import 'package:arch/domain/usecases/delete_todo.dart';

@GenerateMocks([TodoRepository])
import 'delete_todo_test.mocks.dart';

void main() {
  late MockTodoRepository mockRepository;
  late DeleteTodo usecase;

  setUp(() {
    mockRepository = MockTodoRepository();
    usecase = DeleteTodo(mockRepository);
  });

  test('calls repository.deleteTodo', () async {
    const id = '1';
    when(mockRepository.deleteTodo(id)).thenAnswer((_) async {});
    await usecase(id);
    verify(mockRepository.deleteTodo(id)).called(1);
  });

  test('propagates errors', () async {
    const id = '1';
    when(mockRepository.deleteTodo(id)).thenThrow(Exception('error'));
    await expectLater(usecase(id), throwsException);
  });
}
