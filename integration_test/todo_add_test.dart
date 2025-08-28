import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arch/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add todos: all priorities and categories', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    Future<void> addTodo({
      required String title,
      required String priority,
      required String category,
      required String notes,
      DateTime? dueDate,
    }) async {
  final fab = find.byType(FloatingActionButton);
  await tester.pumpAndSettle();
  expect(fab, findsOneWidget, reason: 'FAB should be present before tapping');
  await tester.tap(fab);
  await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Enter todo title'), title);
      await tester.enterText(find.widgetWithText(TextField, 'Category'), category);
      await tester.enterText(find.widgetWithText(TextField, 'Notes'), notes);
      final Finder priorityDropdown = find.byWidgetPredicate((widget) =>
        widget is DropdownButtonFormField && widget.decoration.labelText == 'Priority');
      expect(priorityDropdown, findsOneWidget);
      await tester.tap(priorityDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text(priority).last);
      await tester.pumpAndSettle();
      if (dueDate != null) {
        final dueDateInkWell = find.byWidgetPredicate((widget) {
          if (widget is InkWell) {
            final child = widget.child;
            if (child is InputDecorator && child.decoration.labelText == 'Due Date') {
              return true;
            }
          }
          return false;
        });
        expect(dueDateInkWell, findsOneWidget);
        await tester.tap(dueDateInkWell);
        await tester.pumpAndSettle();
        await tester.tap(find.text('${dueDate.day}'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      }
      final Finder addButton = find.widgetWithText(ElevatedButton, 'Add');
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();
    }

    // Add todos for all priorities and categories
    final priorities = ['Low', 'Medium', 'High'];
    final categories = ['LCAT', 'MCAT', 'HCAT'];
    for (final p in priorities) {
      for (final c in categories) {
        final title = '$p $c Task';
        await addTodo(
          title: title,
          priority: p,
          category: c,
          notes: '$p $c notes',
          dueDate: DateTime.now(),
        );
  // Verify the todo appears in the list
  await tester.pumpAndSettle();
  expect(find.text(title), findsOneWidget);
      }
    }
  });
}
