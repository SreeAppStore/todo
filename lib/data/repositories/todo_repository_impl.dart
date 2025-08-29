import '../../domain/entities/todo.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_data_source.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl(this.localDataSource);

  @override
  Future<List<Todo>> getTodos() async {
    return Future.value(localDataSource.getTodos());
  }

  @override
  Future<void> addTodo(Todo todo) async {
    await localDataSource.addTodo(todo);
  }

  @override
  Future<void> updateTodo(Todo todo) async {
    await localDataSource.updateTodo(todo);
  }

  @override
  Future<void> deleteTodo(String id) async {
    await localDataSource.deleteTodo(id);
  }
}
