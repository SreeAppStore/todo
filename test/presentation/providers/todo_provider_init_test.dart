import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:arch/presentation/providers/todo_provider.dart';
import 'package:arch/domain/usecases/get_todos.dart';
import 'package:arch/domain/usecases/add_todo.dart';
import 'package:arch/domain/usecases/update_todo.dart';
import 'package:arch/domain/usecases/delete_todo.dart';

@GenerateMocks([GetTodos, AddTodo, UpdateTodo, DeleteTodo])
import 'todo_provider_init_test.mocks.dart';

void main() {
  late MockGetTodos mockGetTodos;
  late MockAddTodo mockAddTodo;
  late MockUpdateTodo mockUpdateTodo;
  late MockDeleteTodo mockDeleteTodo;

  setUp(() {
    mockGetTodos = MockGetTodos();
    mockAddTodo = MockAddTodo();
    mockUpdateTodo = MockUpdateTodo();
    mockDeleteTodo = MockDeleteTodo();
    when(mockGetTodos.call()).thenAnswer((_) async => []);
  });

  test('todoListProvider initializes via ProviderContainer', () async {
    final container = ProviderContainer(
      overrides: [
        getTodosProvider.overrideWithValue(mockGetTodos),
        addTodoProvider.overrideWithValue(mockAddTodo),
        updateTodoProvider.overrideWithValue(mockUpdateTodo),
        deleteTodoProvider.overrideWithValue(mockDeleteTodo),
      ],
    );

    // Wait for the first state update before disposing
    final state = await container.read(todoListProvider.notifier).stream.first;
    addTearDown(container.dispose);

    // Assert: state is initialized correctly
    expect(state.allTodos, isEmpty);
    expect(state.filter.search, '');
  });
}
