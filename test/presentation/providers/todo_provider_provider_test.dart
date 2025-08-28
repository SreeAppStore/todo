import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:arch/presentation/providers/todo_provider.dart';
import 'package:arch/domain/usecases/get_todos.dart';
import 'package:arch/domain/usecases/add_todo.dart';
import 'package:arch/domain/usecases/update_todo.dart';
import 'package:arch/domain/usecases/delete_todo.dart';

@GenerateMocks([GetTodos, AddTodo, UpdateTodo, DeleteTodo])
import 'todo_provider_provider_test.mocks.dart';

void main() {
  late MockGetTodos mockGetTodos;
  late MockAddTodo mockAddTodo;
  late MockUpdateTodo mockUpdateTodo;
  late MockDeleteTodo mockDeleteTodo;
  late TodoListNotifier notifier;

  setUp(() {
    mockGetTodos = MockGetTodos();
    mockAddTodo = MockAddTodo();
    mockUpdateTodo = MockUpdateTodo();
    mockDeleteTodo = MockDeleteTodo();
    when(mockGetTodos.call()).thenAnswer((_) async => []);
    notifier = TodoListNotifier(
      getTodos: mockGetTodos,
      addTodo: mockAddTodo,
      updateTodo: mockUpdateTodo,
      deleteTodo: mockDeleteTodo,
    );
  });

  test('TodoListNotifier initializes with empty allTodos', () {
    expect(notifier.state.allTodos, isEmpty);
    expect(notifier.state.filter.search, '');
  });
}