import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di.dart';
import '../../domain/entities/todo.dart';
import '../../domain/usecases/get_todos.dart';
import '../../domain/usecases/add_todo.dart';
import '../../domain/usecases/update_todo.dart';
import '../../domain/usecases/delete_todo.dart';

// Dependency providers for DI and testability
final getTodosProvider = Provider<GetTodos>((ref) => sl<GetTodos>());
final addTodoProvider = Provider<AddTodo>((ref) => sl<AddTodo>());
final updateTodoProvider = Provider<UpdateTodo>((ref) => sl<UpdateTodo>());
final deleteTodoProvider = Provider<DeleteTodo>((ref) => sl<DeleteTodo>());

// Main provider using dependency injection
final todoListProvider = StateNotifierProvider<TodoListNotifier, TodoListState>((ref) =>
    TodoListNotifier(
      getTodos: ref.read(getTodosProvider),
      addTodo: ref.read(addTodoProvider),
      updateTodo: ref.read(updateTodoProvider),
      deleteTodo: ref.read(deleteTodoProvider),
    ));

class TodoFilter {
  final String search;
  final TodoPriority? priority;
  final String? category;
  final String status; // 'All', 'Todo', 'Completed'
  const TodoFilter({this.search = '', this.priority, this.category, this.status = 'All'});
  TodoFilter copyWith({String? search, TodoPriority? priority, String? category, String? status, bool resetPriority = false, bool resetCategory = false}) {
    return TodoFilter(
      search: search ?? this.search,
      priority: resetPriority ? null : (priority ?? this.priority),
      category: resetCategory ? null : (category ?? this.category),
      status: status ?? this.status,
    );
  }
}

class TodoListState {
  final List<Todo> allTodos;
  final TodoFilter filter;
  TodoListState({required this.allTodos, required this.filter});
  List<Todo> filteredTodos({TodoFilter? overrideFilter}) {
    final f = overrideFilter ?? filter;
    var filtered = allTodos.where((todo) {
      final matchesSearch = f.search.isEmpty || todo.title.toLowerCase().contains(f.search.toLowerCase());
      final matchesPriority = f.priority == null || todo.priority == f.priority;
      final matchesCategory = f.category == null || (todo.category ?? '').toLowerCase() == f.category!.toLowerCase();
      return matchesSearch && matchesPriority && matchesCategory;
    }).toList();
    // Status filter
    if (f.status == 'Todo') {
      filtered = filtered.where((t) => !t.completed).toList();
    } else if (f.status == 'Completed') {
      filtered = filtered.where((t) => t.completed).toList();
    }
    print('[Provider] FilteredTodos: filter={search:"${f.search}", priority:${f.priority?.name ?? 'All'}, category:${f.category ?? 'All'}, status:${f.status}} | filteredCount=${filtered.length} | allTodosCount=${allTodos.length}');
    return filtered;
  }

  String get statusFilter => filter.status;
}

class TodoListNotifier extends StateNotifier<TodoListState> {
  Future<void> remove(String id) async {
    final start = DateTime.now();
    print('[Provider] Remove todo: id=$id');
    await deleteTodo(id);
    await loadTodos();
    final elapsed = DateTime.now().difference(start).inMilliseconds;
    print('[Provider] remove() took ${elapsed}ms');
  }
  Future<void> loadTodos() async {
    final start = DateTime.now();
    final todos = await getTodos();
    // Always create a new list instance to force Riverpod to rebuild dependents
    state = TodoListState(allTodos: List<Todo>.from(todos), filter: state.filter);
    final elapsed = DateTime.now().difference(start).inMilliseconds;
    print('[Provider] loadTodos took [1m${elapsed}ms[0m');
  }
  Future<void> _initWithDebugSamples() async {
    await loadTodos();
  }

  Future<void> add(Todo todo) async {
    final start = DateTime.now();
    print('[Provider] Add todo: id=${todo.id}, title=${todo.title}');
    await addTodo(todo);
    await loadTodos();
    final elapsed = DateTime.now().difference(start).inMilliseconds;
    print('[Provider] add() took ${elapsed}ms');
  }

  Future<void> update(Todo todo) async {
    final start = DateTime.now();
    print('[Provider] Update todo: id=${todo.id}, title=${todo.title}');
    await updateTodo(todo);
    await loadTodos();
    final elapsed = DateTime.now().difference(start).inMilliseconds;
    print('[Provider] update() took ${elapsed}ms');
  }

  void setSearch(String search) {
    final start = DateTime.now();
    print('[Provider] Set search: $search');
    final newFilter = state.filter.copyWith(search: search);
    final newState = TodoListState(allTodos: List<Todo>.from(state.allTodos), filter: newFilter);
    print('[Provider] After setSearch: filter={search:"$search", priority:${newFilter.priority?.name ?? 'All'}, category:${newFilter.category ?? 'All'}}');
    print('[Provider] allTodosCount=${newState.allTodos.length}');
    state = newState;
    // Log filtered count immediately after state update
    newState.filteredTodos();
    final elapsed = DateTime.now().difference(start).inMicroseconds;
    print('[Provider] setSearch() took ${elapsed}µs');
  }

  void setPriority(TodoPriority? priority) {
    final start = DateTime.now();
    print('[Provider] Set priority: ${priority?.name ?? 'All'}');
    // If priority is null, reset the filter
    final newFilter = state.filter.copyWith(priority: priority, resetPriority: priority == null);
    final newState = TodoListState(allTodos: List<Todo>.from(state.allTodos), filter: newFilter);
    print('[Provider] After setPriority: filter={search:"${newFilter.search}", priority:${newFilter.priority?.name ?? 'All'}, category:${newFilter.category ?? 'All'}}');
    print('[Provider] allTodosCount=${newState.allTodos.length}');
    state = newState;
    // Log filtered count immediately after state update
    newState.filteredTodos();
    final elapsed = DateTime.now().difference(start).inMicroseconds;
    print('[Provider] setPriority() took ${elapsed}µs');
  }

  void setCategory(String? category) {
    final start = DateTime.now();
    print('[Provider] Set category: ${category ?? 'All'}');
    // If category is null, reset the filter
    final newFilter = state.filter.copyWith(category: category, resetCategory: category == null);
    final newState = TodoListState(allTodos: List<Todo>.from(state.allTodos), filter: newFilter);
    print('[Provider] After setCategory: filter={search:"${newFilter.search}", priority:${newFilter.priority?.name ?? 'All'}, category:${newFilter.category ?? 'All'}}');
    print('[Provider] allTodosCount=${newState.allTodos.length}');
    state = newState;
    // Log filtered count immediately after state update
    newState.filteredTodos();
    final elapsed = DateTime.now().difference(start).inMicroseconds;
    print('[Provider] setCategory() took ${elapsed}µs');
  }
  final GetTodos getTodos;
  final AddTodo addTodo;
  final UpdateTodo updateTodo;
  final DeleteTodo deleteTodo;

  TodoListNotifier({
    required this.getTodos,
    required this.addTodo,
    required this.updateTodo,
    required this.deleteTodo,
  }) : super(TodoListState(allTodos: [], filter: const TodoFilter())) {
    _initWithDebugSamples();
  }


  void setStatusFilter(String status) {
    final newFilter = state.filter.copyWith(status: status);
    final newState = TodoListState(allTodos: List<Todo>.from(state.allTodos), filter: newFilter);
    state = newState;
    newState.filteredTodos();
  }

  // ...existing code...
}
