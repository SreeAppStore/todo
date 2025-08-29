import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arch/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Delete a todo (swipe to delete)', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Add a todo to delete
    final String title = 'Delete Me';
  final fab = find.byType(FloatingActionButton);
  await tester.pumpAndSettle();
  expect(fab, findsOneWidget, reason: 'FAB should be present before tapping');
  await tester.tap(fab);
  await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Enter todo title'), title);
    await tester.enterText(find.widgetWithText(TextField, 'Category'), 'DelCat');
    await tester.enterText(find.widgetWithText(TextField, 'Notes'), 'Del notes');
    final Finder priorityDropdown = find.byWidgetPredicate((widget) =>
      widget is DropdownButtonFormField && widget.decoration.labelText == 'Priority');
    await tester.tap(priorityDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Low').last);
    await tester.pumpAndSettle();
    final Finder addButton = find.widgetWithText(ElevatedButton, 'Add');
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(find.text(title), findsOneWidget);

  // Delete the todo (swipe left)
  final Finder tile = find.ancestor(of: find.text(title), matching: find.byType(ListTile));
  expect(tile, findsOneWidget);
  await tester.drag(tile, const Offset(-300, 0));
  await tester.pumpAndSettle();
  // Confirm the delete dialog
  final Finder deleteDialog = find.text('Delete Task');
  expect(deleteDialog, findsOneWidget);
  final Finder confirmDelete = find.widgetWithText(TextButton, 'Delete');
  expect(confirmDelete, findsOneWidget);
  await tester.tap(confirmDelete);
  await tester.pumpAndSettle();
  // Should be removed from the list
  expect(find.text(title), findsNothing);
  });
}
