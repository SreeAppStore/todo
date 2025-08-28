import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arch/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Delete popup cancel button is not present', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Add a todo to open the popup
    final fab = find.byType(FloatingActionButton);
    await tester.pumpAndSettle();
    expect(fab, findsOneWidget);
    await tester.tap(fab);
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Enter todo title'), 'Popup Cancel Test');
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
    expect(find.text('Popup Cancel Test'), findsOneWidget);

    // Try to find a cancel button in popup (should not exist)
    expect(find.widgetWithText(TextButton, 'Cancel'), findsNothing);
  });
}
