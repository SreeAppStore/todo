import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arch/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Status filter: show only completed/todo tasks', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Add two todos
    final todos = [
      {'title': 'Todo 1', 'category': 'Cat1'},
      {'title': 'Todo 2', 'category': 'Cat2'},
    ];
    for (final t in todos) {
    final fab = find.byType(FloatingActionButton);
    await tester.pumpAndSettle();
    expect(fab, findsOneWidget, reason: 'FAB should be present before tapping');
    await tester.tap(fab);
    await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Enter todo title'), t['title']!);
      await tester.enterText(find.widgetWithText(TextField, 'Category'), t['category']!);
      await tester.enterText(find.widgetWithText(TextField, 'Notes'), 'Notes');
      final Finder priorityDropdown = find.byWidgetPredicate((widget) =>
        widget is DropdownButtonFormField && widget.decoration.labelText == 'Priority');
      await tester.tap(priorityDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Low').last);
      await tester.pumpAndSettle();
      final Finder addButton = find.widgetWithText(ElevatedButton, 'Add');
      await tester.tap(addButton);
      await tester.pumpAndSettle();
      expect(find.text(t['title']!), findsOneWidget);
    }

  // Mark 'Todo 1' as completed (simulate checkbox tap)
  final Finder todo1Tile = find.ancestor(of: find.text('Todo 1'), matching: find.byType(ListTile));
  expect(todo1Tile, findsOneWidget);
  final Finder todo1Checkbox = find.descendant(of: todo1Tile, matching: find.byType(Checkbox));
  expect(todo1Checkbox, findsOneWidget);
  await tester.tap(todo1Checkbox);
  await tester.pumpAndSettle();

    // Open status filter and select Completed
  final Finder statusFilter = find.byIcon(Icons.checklist);
    expect(statusFilter, findsOneWidget);
    await tester.tap(statusFilter);
    await tester.pumpAndSettle();
    final Finder completedMenu = find.text('Completed');
    expect(completedMenu, findsOneWidget);
    await tester.tap(completedMenu);
    await tester.pumpAndSettle();
    // Only completed should be visible
    expect(find.text('Todo 1'), findsOneWidget);
    expect(find.text('Todo 2'), findsNothing);

    // Now select Todo (incomplete) filter
    await tester.tap(statusFilter);
    await tester.pumpAndSettle();
    final Finder todoMenu = find.text('Todo');
    expect(todoMenu, findsOneWidget);
    await tester.tap(todoMenu);
    await tester.pumpAndSettle();
    expect(find.text('Todo 1'), findsNothing);
    expect(find.text('Todo 2'), findsOneWidget);
  });
}
