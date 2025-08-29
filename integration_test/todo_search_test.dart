import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arch/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Search from the edit text', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Add todos
    final todos = [
      {'title': 'Alpha Task', 'category': 'CatA'},
      {'title': 'Beta Task', 'category': 'CatB'},
      {'title': 'Gamma Task', 'category': 'CatC'},
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

  // Search for 'Alpha'
  final Finder searchField = find.widgetWithText(TextField, 'Search todos...');
  expect(searchField, findsOneWidget, reason: 'Search field should be present');
  await tester.enterText(searchField, 'Alpha');
  await tester.pumpAndSettle();
  expect(find.text('Alpha Task'), findsOneWidget);
  expect(find.text('Beta Task'), findsNothing);
  expect(find.text('Gamma Task'), findsNothing);

  // Search for 'Beta'
  await tester.enterText(searchField, 'Beta');
  await tester.pumpAndSettle();
  expect(find.text('Alpha Task'), findsNothing);
  expect(find.text('Beta Task'), findsOneWidget);
  expect(find.text('Gamma Task'), findsNothing);

  // Clear search
  await tester.enterText(searchField, '');
  await tester.pumpAndSettle();
  expect(find.text('Alpha Task'), findsOneWidget);
  expect(find.text('Beta Task'), findsOneWidget);
  expect(find.text('Gamma Task'), findsOneWidget);
  });
}
