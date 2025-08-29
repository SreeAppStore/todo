import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arch/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Popup cancel use case (add/edit)', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Open add popup and cancel
  final fab = find.byType(FloatingActionButton);
  await tester.pumpAndSettle();
  expect(fab, findsOneWidget, reason: 'FAB should be present before tapping');
  await tester.tap(fab);
  await tester.pumpAndSettle();
    final Finder cancelButton = find.widgetWithText(TextButton, 'Cancel');
    expect(cancelButton, findsOneWidget);
    await tester.tap(cancelButton);
    await tester.pumpAndSettle();
    // Should not add any new todo
    expect(find.byType(ListTile), findsNothing);

    // Add a todo to edit
    final String title = 'Cancel Edit';
    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Enter todo title'), title);
    await tester.enterText(find.widgetWithText(TextField, 'Category'), 'Cat');
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
    expect(find.text(title), findsOneWidget);

    // Open edit popup and cancel
    final Finder tile = find.ancestor(of: find.text(title), matching: find.byType(ListTile));
    final Finder editIcon = find.descendant(of: tile, matching: find.byIcon(Icons.edit));
    await tester.tap(editIcon);
    await tester.pumpAndSettle();
    final Finder editCancelButton = find.widgetWithText(TextButton, 'Cancel');
    expect(editCancelButton, findsOneWidget);
    await tester.tap(editCancelButton);
    await tester.pumpAndSettle();
    // Should not change the todo
    expect(find.text(title), findsOneWidget);
  });
}
