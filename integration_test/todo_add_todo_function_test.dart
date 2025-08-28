import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arch/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Add todo using _addTodo function logic', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Add a todo with only title (simulating _addTodo logic)
    final fab = find.byType(FloatingActionButton);
    await tester.pumpAndSettle();
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Enter todo title'), 'AddTodo Function Test');
    final Finder addButton = find.widgetWithText(ElevatedButton, 'Add');
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    // Should be present in the list
    expect(find.text('AddTodo Function Test'), findsOneWidget);
  });
}
