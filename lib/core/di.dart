import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/datasources/todo_local_data_source.dart';
import '../data/repositories/todo_repository_impl.dart';
import '../domain/repositories/todo_repository.dart';
import '../domain/usecases/add_todo.dart';
import '../domain/usecases/delete_todo.dart';
import '../domain/usecases/get_todos.dart';
import '../domain/usecases/update_todo.dart';

final sl = GetIt.instance;

Future<void> initDI() async {
  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters before opening any box
  TodoLocalDataSource.registerAdapter();

  // Data sources
  sl.registerLazySingleton<TodoLocalDataSource>(() => TodoLocalDataSource());
  await sl<TodoLocalDataSource>().init();

  // Repository
  sl.registerLazySingleton<TodoRepository>(
    () => TodoRepositoryImpl(sl<TodoLocalDataSource>()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetTodos(sl<TodoRepository>()));
  sl.registerLazySingleton(() => AddTodo(sl<TodoRepository>()));
  sl.registerLazySingleton(() => UpdateTodo(sl<TodoRepository>()));
  sl.registerLazySingleton(() => DeleteTodo(sl<TodoRepository>()));
}
