import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arch/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Date picker opens and sets date', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Add a todo to open the date picker
    final fab = find.byType(FloatingActionButton);
    await tester.pumpAndSettle();
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Enter todo title'), 'Date Picker Test');
    await tester.enterText(find.widgetWithText(TextField, 'Category'), 'Cat');
    await tester.enterText(find.widgetWithText(TextField, 'Notes'), 'Notes');
    final Finder priorityDropdown = find.byWidgetPredicate((widget) =>
      widget is DropdownButtonFormField && widget.decoration.labelText == 'Priority');
    await tester.tap(priorityDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Low').last);
    await tester.pumpAndSettle();
  // Open date picker by tapping the InputDecorator labeled 'Due Date'
  final dueDateField = find.widgetWithText(InputDecorator, 'Select date');
  expect(dueDateField, findsOneWidget);
  await tester.tap(dueDateField);
  await tester.pumpAndSettle();
  // Date picker should be present
  expect(find.byType(DatePickerDialog), findsOneWidget);
  });
}
