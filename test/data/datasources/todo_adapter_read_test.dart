
import 'package:flutter_test/flutter_test.dart';
import 'package:arch/data/datasources/todo_local_data_source.dart';
import 'package:arch/domain/entities/todo.dart';
import 'package:hive/hive.dart';

class FakeBinaryReader implements BinaryReader {
  final List<dynamic> _values;
  int _index = 0;
  FakeBinaryReader(this._values);
  @override
  dynamic read([int? typeId]) => _values[_index++];
  @override
  int readByte() => _values[_index++];
  // All other members throw or return dummy values
  noSuchMethod(Invocation invocation) => throw UnimplementedError('FakeBinaryReader: \\${invocation.memberName}');
}

void main() {
  test('TodoAdapter.read reconstructs Todo from fields', () {
    // Simulate the binary data for a Todo
    // 7 fields: id, title, completed, dueDate, priority, category, notes
    final id = 'id';
    final title = 'title';
    final completed = true;
    final dueDate = DateTime(2025, 8, 17);
    final priority = TodoPriority.high.index;
    final category = 'cat';
    final notes = 'notes';
    // numOfFields, then for each: fieldKey, value
    final fakeData = [
      7, // numOfFields
      0, id,
      1, title,
      2, completed,
      3, dueDate,
      4, priority,
      5, category,
      6, notes,
    ];
    final reader = FakeBinaryReader(fakeData);
    final adapter = TodoAdapter();
    final todo = adapter.read(reader);
    expect(todo.id, id);
    expect(todo.title, title);
    expect(todo.completed, completed);
    expect(todo.dueDate, dueDate);
    expect(todo.priority, TodoPriority.high);
    expect(todo.category, category);
    expect(todo.notes, notes);
  });
}
