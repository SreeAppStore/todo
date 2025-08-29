import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arch/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Priority and category filter flows', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Add todos for all priorities and categories
    final priorities = ['Low', 'Medium', 'High'];
    final categories = ['LCAT', 'MCAT', 'HCAT'];
    for (final p in priorities) {
      for (final c in categories) {
        final title = '$p $c Task';
        final fab = find.byType(FloatingActionButton);
        await tester.pumpAndSettle();
        expect(fab, findsOneWidget, reason: 'FAB should be present before tapping');
        await tester.tap(fab);
        await tester.pumpAndSettle();
        await tester.enterText(find.widgetWithText(TextField, 'Enter todo title'), title);
        await tester.enterText(find.widgetWithText(TextField, 'Category'), c);
        await tester.enterText(find.widgetWithText(TextField, 'Notes'), '$p $c notes');
        final Finder priorityDropdown = find.byWidgetPredicate((widget) =>
          widget is DropdownButtonFormField && widget.decoration.labelText == 'Priority');
        await tester.tap(priorityDropdown);
        await tester.pumpAndSettle();
        await tester.tap(find.text(p).last);
        await tester.pumpAndSettle();
        final Finder addButton = find.widgetWithText(ElevatedButton, 'Add');
        await tester.tap(addButton);
        await tester.pumpAndSettle();
        expect(find.text(title), findsOneWidget);
      }
    }

    // Test all priority/category filter combinations
    for (final p in priorities) {
      for (final c in categories) {
        // Set priority filter
        final Finder priorityFilter = find.byIcon(Icons.flag);
        await tester.tap(priorityFilter.first);
        await tester.pumpAndSettle();
        final String menuText = p == 'All' ? 'All Priorities' : (p[0].toUpperCase() + p.substring(1));
        final Finder menuItem = find.text(menuText);
        await tester.tap(menuItem.last);
        await tester.pumpAndSettle();
        // Set category filter
        final Finder categoryFilter = find.byIcon(Icons.label);
        await tester.tap(categoryFilter.first);
        await tester.pumpAndSettle();
        final String catMenuText = c == 'All' ? 'All Categories' : c;
        final Finder catMenuItem = find.text(catMenuText);
        await tester.tap(catMenuItem.last);
        await tester.pumpAndSettle();
        // Only the matching todo should be visible
        final String expectedTitle = '$p $c Task';
        expect(find.text(expectedTitle), findsOneWidget);
      }
    }
  });
}
