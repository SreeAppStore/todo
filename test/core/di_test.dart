import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:arch/core/di.dart';
import 'package:arch/data/datasources/todo_local_data_source.dart';
import 'package:arch/data/repositories/todo_repository_impl.dart';
import 'package:arch/domain/repositories/todo_repository.dart';
import 'package:arch/domain/usecases/add_todo.dart';
import 'package:arch/domain/usecases/delete_todo.dart';
import 'package:arch/domain/usecases/get_todos.dart';
import 'package:arch/domain/usecases/update_todo.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'dart:io';

class FakePathProviderPlatform extends PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() async {
    final dir = Directory.systemTemp.createTempSync();
    return dir.path;
  }
}
void main() {
  test('initDI registers all dependencies', () async {
    // Patch the path provider so Hive.initFlutter() works in tests
    PathProviderPlatform.instance = FakePathProviderPlatform();
    await Hive.initFlutter();
    await initDI();
    expect(sl<TodoLocalDataSource>(), isA<TodoLocalDataSource>());
    expect(sl<TodoRepository>(), isA<TodoRepositoryImpl>());
    expect(sl<GetTodos>(), isA<GetTodos>());
    expect(sl<AddTodo>(), isA<AddTodo>());
    expect(sl<UpdateTodo>(), isA<UpdateTodo>());
    expect(sl<DeleteTodo>(), isA<DeleteTodo>());
  });
}
