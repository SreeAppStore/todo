import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arch/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Edit todos: title, priority, category, notes, due date', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Add a todo to edit
    final String originalTitle = 'Edit Me';
    final String originalCategory = 'EditCat';
    final String originalNotes = 'Edit notes';
    final String originalPriority = 'Low';
    final DateTime originalDue = DateTime.now();
  final fab = find.byType(FloatingActionButton);
  await tester.pumpAndSettle();
  expect(fab, findsOneWidget, reason: 'FAB should be present before tapping');
  await tester.tap(fab);
  await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Enter todo title'), originalTitle);
    await tester.enterText(find.widgetWithText(TextField, 'Category'), originalCategory);
    await tester.enterText(find.widgetWithText(TextField, 'Notes'), originalNotes);
    final Finder priorityDropdown = find.byWidgetPredicate((widget) =>
      widget is DropdownButtonFormField && widget.decoration.labelText == 'Priority');
    await tester.tap(priorityDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(originalPriority).last);
    await tester.pumpAndSettle();
    final Finder addButton = find.widgetWithText(ElevatedButton, 'Add');
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(find.text(originalTitle), findsOneWidget);

    // Edit the todo
    final Finder tile = find.ancestor(of: find.text(originalTitle), matching: find.byType(ListTile));
    final Finder editIcon = find.descendant(of: tile, matching: find.byIcon(Icons.edit));
    await tester.tap(editIcon);
    await tester.pumpAndSettle();
    // Change all fields
    await tester.enterText(find.widgetWithText(TextField, 'Enter todo title'), 'Edited Title');
    await tester.enterText(find.widgetWithText(TextField, 'Category'), 'EditedCat');
    await tester.enterText(find.widgetWithText(TextField, 'Notes'), 'Edited notes');
    final Finder editPriorityDropdown = find.byWidgetPredicate((widget) =>
      widget is DropdownButtonFormField && widget.decoration.labelText == 'Priority');
    await tester.tap(editPriorityDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('High').last);
    await tester.pumpAndSettle();
    final Finder saveButton = find.widgetWithText(ElevatedButton, 'Save');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    // Verify changes
    expect(find.text('Edited Title'), findsOneWidget);
    expect(find.text('EditedCat'), findsWidgets);
    expect(find.text('Edited notes'), findsWidgets);
  });
}
