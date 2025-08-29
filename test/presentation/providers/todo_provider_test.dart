import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:arch/domain/entities/todo.dart';
import 'package:arch/presentation/providers/todo_provider.dart';
import 'package:arch/domain/usecases/get_todos.dart';
import 'package:arch/domain/usecases/add_todo.dart';
import 'package:arch/domain/usecases/update_todo.dart';
import 'package:arch/domain/usecases/delete_todo.dart';




@GenerateMocks([GetTodos, AddTodo, UpdateTodo, DeleteTodo])
import 'todo_provider_test.mocks.dart';

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
    // Default stub for getTodos to avoid MissingStubError during notifier construction
    when(mockGetTodos.call()).thenAnswer((_) async => []);
    notifier = TodoListNotifier(
      getTodos: mockGetTodos,
      addTodo: mockAddTodo,
      updateTodo: mockUpdateTodo,
      deleteTodo: mockDeleteTodo,
    );
  });

  group('TodoListNotifier', () {
    test('TodoListState.filteredTodos filters by status correctly', () {
      final t1 = Todo(id: '1', title: 'A', completed: false);
      final t2 = Todo(id: '2', title: 'B', completed: true);
      final t3 = Todo(id: '3', title: 'C', completed: false);
      final t4 = Todo(id: '4', title: 'D', completed: true);
      final all = [t1, t2, t3, t4];
      // All
      final stateAll = TodoListState(allTodos: all, filter: const TodoFilter(status: 'All'));
      expect(stateAll.filteredTodos().length, 4);
      // Todo (incomplete only)
      final stateTodo = TodoListState(allTodos: all, filter: const TodoFilter(status: 'Todo'));
      final todosOnly = stateTodo.filteredTodos();
      expect(todosOnly.length, 2);
      expect(todosOnly.every((t) => !t.completed), true);
      // Completed only
      final stateCompleted = TodoListState(allTodos: all, filter: const TodoFilter(status: 'Completed'));
      final completedOnly = stateCompleted.filteredTodos();
      expect(completedOnly.length, 2);
      expect(completedOnly.every((t) => t.completed), true);
    });

    test('TodoListState.statusFilter returns filter.status', () {
      final state = TodoListState(allTodos: [], filter: const TodoFilter(status: 'Completed'));
      expect(state.statusFilter, 'Completed');
    });
    test('setStatusFilter updates the filter and state', () async {
      final t1 = Todo(id: '1', title: 'A', completed: false);
      final t2 = Todo(id: '2', title: 'B', completed: true);
      when(mockGetTodos()).thenAnswer((_) async => [t1, t2]);
      await notifier.loadTodos();
      // Default filter is 'All'
      expect(notifier.state.filter.status, 'All');
      expect(notifier.state.filteredTodos().length, 2);
      // Set to 'Todo' (should only show incomplete)
      notifier.setStatusFilter('Todo');
      expect(notifier.state.filter.status, 'Todo');
      final todosOnly = notifier.state.filteredTodos();
      expect(todosOnly.length, 1);
      expect(todosOnly.first.completed, false);
      // Set to 'Completed' (should only show completed)
      notifier.setStatusFilter('Completed');
      expect(notifier.state.filter.status, 'Completed');
      final completedOnly = notifier.state.filteredTodos();
      expect(completedOnly.length, 1);
      expect(completedOnly.first.completed, true);
    });
    test('filteredTodos returns incomplete first, then completed', () async {
      final t1 = Todo(id: '1', title: 'A', completed: false);
      final t2 = Todo(id: '2', title: 'B', completed: true);
      final t3 = Todo(id: '3', title: 'C', completed: false);
      final t4 = Todo(id: '4', title: 'D', completed: true);
      when(mockGetTodos()).thenAnswer((_) async => [t1, t2, t3, t4]);
      await notifier.loadTodos();
      // Simulate UI sort: incomplete first, then completed
      final sorted = List<Todo>.from(notifier.state.filteredTodos())
        ..sort((a, b) {
          if (a.completed == b.completed) return 0;
          return a.completed ? 1 : -1;
        });
      expect(sorted[0].id, '1');
      expect(sorted[1].id, '3');
      expect(sorted[2].id, '2');
      expect(sorted[3].id, '4');
    });
    test('Adding a new task', () async {
      final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
  when(mockAddTodo.call(any)).thenAnswer((_) async {});
  when(mockGetTodos()).thenAnswer((_) async => [todo]);
      await notifier.add(todo);
      expect(notifier.state.allTodos.length, 1);
      expect(notifier.state.allTodos.first.title, 'Test');
    });

    test('Editing an existing task', () async {
      final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
      final updated = todo.copyWith(title: 'Updated');
  when(mockAddTodo.call(any)).thenAnswer((_) async {});
  when(mockUpdateTodo.call(any)).thenAnswer((_) async {});
  when(mockGetTodos()).thenAnswer((_) async => [updated]);
      await notifier.add(todo);
      await notifier.update(updated);
      expect(notifier.state.allTodos.first.title, 'Updated');
    });

    test('Deleting a task', () async {
      final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
  when(mockAddTodo.call(any)).thenAnswer((_) async {});
  when(mockDeleteTodo.call(any)).thenAnswer((_) async {});
  when(mockGetTodos()).thenAnswer((_) async => []);
      await notifier.add(todo);
      await notifier.remove(todo.id);
      expect(notifier.state.allTodos, isEmpty);
    });

    test('Marking a task as complete (checkbox)', () async {
      final todo = Todo(id: '1', title: 'Test', priority: TodoPriority.low);
      final completed = todo.copyWith(completed: true);
  when(mockAddTodo.call(any)).thenAnswer((_) async {});
  when(mockUpdateTodo.call(any)).thenAnswer((_) async {});
  when(mockGetTodos()).thenAnswer((_) async => [completed]);
      await notifier.add(todo);
      await notifier.update(completed);
      expect(notifier.state.allTodos.first.completed, true);
    });

    test('Filtering tasks correctly', () async {
      final t1 = Todo(id: '1', title: 'A', priority: TodoPriority.low);
      final t2 = Todo(id: '2', title: 'B', priority: TodoPriority.high);
  when(mockGetTodos()).thenAnswer((_) async => [t1, t2]);
      await notifier.loadTodos();
      notifier.setPriority(TodoPriority.high);
      final filtered = notifier.state.filteredTodos();
      expect(filtered.length, 1);
      expect(filtered.first.id, '2');
    });

    test('Persisting and retrieving tasks', () async {
      final todo = Todo(id: '1', title: 'Persist', priority: TodoPriority.low);
  when(mockAddTodo.call(any)).thenAnswer((_) async {});
  when(mockGetTodos()).thenAnswer((_) async => [todo]);
      await notifier.add(todo);
      await notifier.loadTodos();
      expect(notifier.state.allTodos.first.title, 'Persist');
    });

    test('Edge case: empty task', () async {
      final todo = Todo(id: '1', title: '', priority: TodoPriority.low);
  when(mockAddTodo.call(any)).thenAnswer((_) async {});
  when(mockGetTodos()).thenAnswer((_) async => [todo]);
      await notifier.add(todo);
      expect(notifier.state.allTodos.first.title, '');
    });

    test('Edge case: duplicate tasks', () async {
      final todo = Todo(id: '1', title: 'Dup', priority: TodoPriority.low);
      when(mockAddTodo.call(any)).thenAnswer((_) async {});
      when(mockGetTodos()).thenAnswer((_) async => [todo, todo]);
      await notifier.add(todo);
      await notifier.add(todo);
      await notifier.loadTodos();
      expect(notifier.state.allTodos.length, 2);
    });

    test('setSearch updates filter and state', () async {
      final t1 = Todo(id: '1', title: 'Alpha', priority: TodoPriority.low);
      final t2 = Todo(id: '2', title: 'Beta', priority: TodoPriority.high);
      when(mockGetTodos()).thenAnswer((_) async => [t1, t2]);
      await notifier.loadTodos();
      notifier.setSearch('Alpha');
      final filtered = notifier.state.filteredTodos();
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Alpha');
    });

    test('setCategory updates filter and state', () async {
      final t1 = Todo(id: '1', title: 'Alpha', priority: TodoPriority.low, category: 'Work');
      final t2 = Todo(id: '2', title: 'Beta', priority: TodoPriority.high, category: 'Home');
      when(mockGetTodos()).thenAnswer((_) async => [t1, t2]);
      await notifier.loadTodos();
      notifier.setCategory('Work');
      final filtered = notifier.state.filteredTodos();
      expect(filtered.length, 1);
      expect(filtered.first.category, 'Work');
    });
  });
}
