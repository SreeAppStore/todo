import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:arch/main.dart' as app;
import 'package:flutter/material.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full todo flow: add, edit, remove, verify at each step', (WidgetTester tester) async {
    Future<void> stepDelay([int ms = 100]) async {
      await tester.pumpAndSettle(const Duration(milliseconds: 100));
      await Future.delayed(Duration(milliseconds: ms));
    }
    app.main();
    await tester.pumpAndSettle();

    Future<void> setFilter({String? priority, String? category}) async {
      if (priority != null) {
        final Finder priorityFilter = find.byIcon(Icons.flag);
        if (tester.any(priorityFilter)) {
          await tester.tap(priorityFilter.first);
          await tester.pumpAndSettle();
          final String menuText =
              priority == 'All' ? 'All Priorities' : (priority[0].toUpperCase() + priority.substring(1));
          final Finder menuItem = find.text(menuText);
          if (tester.any(menuItem)) {
            await tester.tap(menuItem.last);
            await tester.pumpAndSettle();
            await stepDelay();
          } else {
            await tester.tapAt(const Offset(10, 10));
            await tester.pumpAndSettle();
          }
        }
      }
      if (category != null) {
        final Finder categoryFilter = find.byIcon(Icons.label);
        if (tester.any(categoryFilter)) {
          await tester.tap(categoryFilter.first);
          await tester.pumpAndSettle();
          final String menuText = category == 'All' ? 'All Categories' : category;
          final Finder menuItem = find.text(menuText);
          if (tester.any(menuItem)) {
            await tester.tap(menuItem.last);
            await tester.pumpAndSettle();
            await stepDelay();
          } else {
            await tester.tapAt(const Offset(10, 10));
            await tester.pumpAndSettle();
          }
        }
      }
    }

    Future<void> clearFilters() async {
      await setFilter(priority: 'All');
      await setFilter(category: 'All');
    }

    final priorities = ['Low', 'Medium', 'High'];
    final categories = ['LCAT', 'MCAT', 'HCAT'];
  final List<Map<String, String>> tasks = [];
  final List<Map<String, String>> completedTasks = [];

  Future<void> verifyTasksInUI(List<Map<String, String>> expectedTasks, {bool showCompleted = false}) async {
      await tester.pumpAndSettle();
      // Debug: print visible tasks
      final visible = <String>[];
      for (final title in ['Low Task', 'Medium Task', 'High Task', 'Low Task Edited']) {
        if (find.text(title).evaluate().isNotEmpty) visible.add(title);
      }
      // ignore: avoid_print
      print('[DEBUG] Expecting: ${expectedTasks.map((t) => t['title']).toList()} | Visible: $visible');
      // Check incomplete tasks (main list)
      for (final t in expectedTasks) {
        expect(find.text(t['title']!), findsOneWidget, reason: 'Should show ${t['title']} (incomplete)');
      }
      for (final title in ['Low Task', 'Medium Task', 'High Task', 'Low Task Edited']) {
        final finder = find.text(title);
        if (expectedTasks.any((t) => t['title'] == title)) {
          // Should be visible and not completed (no strikethrough)
          expect(finder, findsOneWidget, reason: 'Should show $title (incomplete)');
          if (finder.evaluate().isNotEmpty) {
            final textWidget = finder.evaluate().first.widget as Text;
            expect(textWidget.style?.decoration, isNot(TextDecoration.lineThrough), reason: '$title should not have strikethrough');
          }
        } else if (completedTasks.any((t) => t['title'] == title)) {
          // If present, must have strikethrough
          if (finder.evaluate().isNotEmpty) {
            final textWidget = finder.evaluate().first.widget as Text;
            expect(textWidget.style?.decoration, TextDecoration.lineThrough, reason: 'Completed $title should have strikethrough');
          }
        } else {
          expect(finder, findsNothing, reason: 'Should not show $title');
        }
      }
      // Check completed tasks only if showCompleted is true
      if (showCompleted) {
        for (final t in completedTasks) {
          expect(find.text(t['title']!), findsOneWidget, reason: 'Should show ${t['title']} (completed)');
        }
      }
    }

    Future<void> verifyAllFilters(List<Map<String, String>> currentTasks) async {
      for (final p in priorities) {
        for (final c in categories) {
          await setFilter(priority: p, category: c);
          await tester.pumpAndSettle();
          final expected = currentTasks.where((t) => t['priority'] == p && t['category'] == c).toList();
          // Debug: print current filter
          // ignore: avoid_print
          print('[DEBUG] Filter: priority=$p, category=$c');
          await verifyTasksInUI(expected, showCompleted: false);
        }
      }
      // Also check completed filter
      await setFilter(priority: 'All', category: 'All');
      // Open status filter and select Completed
      final Finder statusFilter = find.byIcon(Icons.check_circle_outline);
      if (tester.any(statusFilter)) {
        await tester.tap(statusFilter.first);
        await tester.pumpAndSettle();
        final Finder completedMenu = find.text('Completed');
        if (tester.any(completedMenu)) {
          await tester.tap(completedMenu.last);
          await tester.pumpAndSettle();
          // Now only completed tasks should be visible
          await verifyTasksInUI([], showCompleted: true);
        }
      }
      await clearFilters();
      await tester.pumpAndSettle();
    }

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
  await stepDelay();

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
  await stepDelay();

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
  await stepDelay();
      }

      final Finder addButton = find.widgetWithText(ElevatedButton, 'Add');
      expect(addButton, findsOneWidget);
      await tester.tap(addButton);
      await tester.pumpAndSettle();
  await stepDelay();
    }

  // 1. Add Low Task
  await addTodo(title: 'Low Task', priority: 'Low', category: 'LCAT', notes: 'Low notes', dueDate: DateTime.now());
  tasks.add({'title': 'Low Task', 'priority': 'Low', 'category': 'LCAT'});
  await verifyTasksInUI(tasks);

  // 2. Add Medium Task
  await addTodo(title: 'Medium Task', priority: 'Medium', category: 'MCAT', notes: 'Medium notes', dueDate: DateTime.now());
  tasks.add({'title': 'Medium Task', 'priority': 'Medium', 'category': 'MCAT'});
  await verifyTasksInUI(tasks);

  // 3. Add High Task
  await addTodo(title: 'High Task', priority: 'High', category: 'HCAT', notes: 'High notes', dueDate: DateTime.now());
  tasks.add({'title': 'High Task', 'priority': 'High', 'category': 'HCAT'});
  await verifyTasksInUI(tasks);

  // Now test filters
  await verifyAllFilters(tasks);

  // Ensure filters are cleared before editing
  await clearFilters();
  await tester.pumpAndSettle();
  // Debug: print visible tasks before edit
  final visibleBeforeEdit = <String>[];
  for (final title in ['Low Task', 'Medium Task', 'High Task', 'Low Task Edited']) {
    if (find.text(title).evaluate().isNotEmpty) visibleBeforeEdit.add(title);
  }
  // ignore: avoid_print
  print('[DEBUG] Visible before edit: ' + visibleBeforeEdit.toString());

    // 4. Edit Low Task to Low Task Edited, change priority to Medium
    final Finder lowTile = find.ancestor(of: find.text('Low Task'), matching: find.byType(ListTile));
    final Finder lowEditIcon = find.descendant(of: lowTile, matching: find.byIcon(Icons.edit));
    await tester.tap(lowEditIcon);
    await tester.pumpAndSettle();
    final Finder editTitleField = find.widgetWithText(TextField, 'Enter todo title');
    await tester.enterText(editTitleField, 'Low Task Edited');
    final Finder editPriorityDropdown = find.byWidgetPredicate((widget) =>
      widget is DropdownButtonFormField && widget.decoration.labelText == 'Priority');
    await tester.tap(editPriorityDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Medium').last);
    await tester.pumpAndSettle();
    final Finder saveButton = find.widgetWithText(ElevatedButton, 'Save');
    await tester.tap(saveButton);
    await tester.pumpAndSettle();
    // Update tasks list
    tasks.removeWhere((t) => t['title'] == 'Low Task');
    tasks.add({'title': 'Low Task Edited', 'priority': 'Medium', 'category': 'LCAT'});
  await verifyTasksInUI(tasks);
  await verifyAllFilters(tasks);

    // 5. Remove High Task
  final Finder highTile = find.ancestor(of: find.text('High Task'), matching: find.byType(ListTile));
  expect(highTile, findsOneWidget);
  await tester.drag(highTile, const Offset(300, 0)); // swipe right
  await tester.pumpAndSettle();
  await stepDelay();
  // Move to completedTasks
  final removed = tasks.firstWhere((t) => t['title'] == 'High Task');
  tasks.removeWhere((t) => t['title'] == 'High Task');
  completedTasks.add(removed);
  await verifyTasksInUI(tasks);
  await verifyAllFilters(tasks);

    // 6. Remove Low Task Edited
  final Finder editedLowTile = find.ancestor(of: find.text('Low Task Edited'), matching: find.byType(ListTile));
  expect(editedLowTile, findsOneWidget);
  await tester.drag(editedLowTile, const Offset(300, 0));
  await tester.pumpAndSettle();
  await stepDelay();
  final removedLow = tasks.firstWhere((t) => t['title'] == 'Low Task Edited');
  tasks.removeWhere((t) => t['title'] == 'Low Task Edited');
  completedTasks.add(removedLow);
  await verifyTasksInUI(tasks);
  await verifyAllFilters(tasks);

    // 7. Remove Medium Task
  final Finder mediumTile = find.ancestor(of: find.text('Medium Task'), matching: find.byType(ListTile));
  expect(mediumTile, findsOneWidget);
  await tester.drag(mediumTile, const Offset(300, 0));
  await tester.pumpAndSettle();
  await stepDelay();
  final removedMed = tasks.firstWhere((t) => t['title'] == 'Medium Task');
  tasks.removeWhere((t) => t['title'] == 'Medium Task');
  completedTasks.add(removedMed);
  await verifyTasksInUI(tasks);
  await verifyAllFilters(tasks);
  });
}
