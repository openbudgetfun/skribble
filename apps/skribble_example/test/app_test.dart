import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/app.dart';
import 'package:skribble_example/models/note.dart';
import 'package:skribble_example/pages/edit_page.dart';
import 'package:skribble_example/widgets/drawer_menu.dart';
import 'package:skribble_example/widgets/note_card.dart';

/// Helper to wrap a widget in a [WiredMaterialApp] with a theme.
Widget _wrapInApp(Widget child) {
  return WiredMaterialApp(
    wiredTheme: WiredThemeData(
      borderColor: const Color(0xFF5C3D2E),
      textColor: const Color(0xFF2E2E2E),
      disabledTextColor: const Color(0xFFA89888),
      fillColor: const Color(0xFFF5ECD7),
      roughness: 1.2,
    ),
    home: child,
  );
}

/// Create a sample [Note] for testing purposes.
Note _sampleNote({
  String id = 'test-1',
  String title = 'Test Title',
  String content = 'Test content for the note.',
  Color color = const Color(0xFFF5ECD7),
  DateTime? createdAt,
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return Note(
    id: id,
    title: title,
    content: content,
    color: color,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
  );
}

void main() {
  group('SketchNotesApp', () {
    testWidgets('renders without error', (tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();
      expect(find.byType(SketchNotesApp), findsOneWidget);
    });

    testWidgets('home page shows "Sketch Notes" title', (tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();
      expect(find.text('Sketch Notes'), findsOneWidget);
    });

    testWidgets('sample notes are visible', (tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Sketch Notes'), findsOneWidget);
      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Project Ideas'), findsOneWidget);
    });

    testWidgets('FAB is present', (tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();
      expect(
        find.bySemanticsLabel('Create new note'),
        findsOneWidget,
      );
    });

    testWidgets('tapping FAB navigates to edit page', (tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();

      await tester.tap(find.bySemanticsLabel('Create new note'));
      await tester.pumpAndSettle();

      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('settings page renders', (tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();

      // Navigate to settings via the Navigator.
      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      unawaited(navigator.pushNamed('/settings'));
      // WiredSlider schedules a zero-duration Future on each build,
      // so we pump enough frames for the route transition to complete.
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.text('Dark Mode'), findsOneWidget);

      // Pop back to home so the WiredSlider's pending timer is
      // disposed before the test ends.
      navigator.pop();
      await tester.pumpAndSettle();
    });
  });

  group('Note model', () {
    test('Note.create generates unique IDs', () {
      final note1 = Note.create(title: 'A');
      final note2 = Note.create(title: 'B');
      expect(note1.id, isNot(equals(note2.id)));
    });

    test('copyWith updates fields', () {
      final note = Note.create(title: 'Original', content: 'Content');
      final updated = note.copyWith(title: 'Updated');
      expect(updated.title, 'Updated');
      expect(updated.content, 'Content');
      expect(updated.id, note.id);
    });

    test('copyWith preserves all unchanged fields', () {
      final note = Note.create(
        title: 'Title',
        content: 'Content',
        color: const Color(0xFFE8F5E9),
      );
      final updated = note.copyWith(content: 'New content');
      expect(updated.title, 'Title');
      expect(updated.content, 'New content');
      expect(updated.color, const Color(0xFFE8F5E9));
      expect(updated.id, note.id);
      expect(updated.createdAt, note.createdAt);
    });

    test('Note.create default color is parchment (0xFFF5ECD7)', () {
      final note = Note.create(title: 'Default color test');
      expect(note.color, const Color(0xFFF5ECD7));
    });

    test('Note.create sets createdAt and updatedAt to now', () {
      final before = DateTime.now();
      final note = Note.create(title: 'Time test');
      final after = DateTime.now();
      expect(note.createdAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
      expect(note.createdAt.isBefore(after.add(const Duration(seconds: 1))), isTrue);
      expect(note.updatedAt.isAfter(before.subtract(const Duration(seconds: 1))), isTrue);
    });

    test('copyWith with color changes only the color', () {
      final note = Note.create(title: 'A', content: 'B');
      final updated = note.copyWith(color: const Color(0xFFE3F2FD));
      expect(updated.color, const Color(0xFFE3F2FD));
      expect(updated.title, 'A');
      expect(updated.content, 'B');
    });
  });

  group('Home page', () {
    testWidgets('search bar is present with hint text', (tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();
      expect(find.text('Search notes...'), findsOneWidget);
    });

    testWidgets('search filters notes by title', (tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();

      // All three notes visible initially.
      expect(find.text('Welcome to Sketch Notes'), findsOneWidget);
      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Project Ideas'), findsOneWidget);

      // Type into the search bar. WiredSearchBar wraps a TextField.
      await tester.enterText(find.byType(TextField).first, 'Shopping');
      await tester.pumpAndSettle();

      // Only Shopping List should remain visible.
      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Welcome to Sketch Notes'), findsNothing);
      expect(find.text('Project Ideas'), findsNothing);
    });

    testWidgets('search filtering shows "No notes match" when nothing matches',
        (tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byType(TextField).first,
        'xyznonexistent',
      );
      await tester.pumpAndSettle();

      expect(find.text('No notes match your search.'), findsOneWidget);
    });

    testWidgets('search filters notes by content', (tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();

      // Search for content present only in the Shopping List note.
      await tester.enterText(find.byType(TextField).first, 'coffee beans');
      await tester.pumpAndSettle();

      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Welcome to Sketch Notes'), findsNothing);
      expect(find.text('Project Ideas'), findsNothing);
    });

    testWidgets('drawer opens when tapping menu button', (tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();

      // Tap the menu icon button.
      await tester.tap(find.bySemanticsLabel('Open menu'));
      await tester.pumpAndSettle();

      // Drawer should now be visible with its contents.
      expect(find.text('All Notes'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });
  });

  group('Edit page', () {
    testWidgets('renders title and content input fields for new note',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(const EditPage()));
      await tester.pumpAndSettle();

      // "New Note" title in the app bar.
      expect(find.text('New Note'), findsOneWidget);
      // Hint texts for the input fields.
      expect(find.text('Note title...'), findsOneWidget);
      expect(find.text('Write your thoughts...'), findsOneWidget);
    });

    testWidgets('save button shows "Create Note" for new notes',
        (tester) async {
      await tester.pumpWidget(_wrapInApp(const EditPage()));
      await tester.pumpAndSettle();

      expect(find.text('Create Note'), findsOneWidget);
    });

    testWidgets('color chips are displayed with all labels', (tester) async {
      await tester.pumpWidget(_wrapInApp(const EditPage()));
      await tester.pumpAndSettle();

      expect(find.text('Label color'), findsOneWidget);
      expect(find.text('Parchment'), findsOneWidget);
      expect(find.text('Green'), findsOneWidget);
      expect(find.text('Blue'), findsOneWidget);
      expect(find.text('Orange'), findsOneWidget);
      expect(find.text('Purple'), findsOneWidget);
    });

    testWidgets('editing an existing note pre-fills fields and shows Edit title',
        (tester) async {
      final existingNote = _sampleNote(
        title: 'My Existing Note',
        content: 'Existing content here.',
      );

      // Build an app that navigates to EditPage with the note as argument.
      await tester.pumpWidget(
        WiredMaterialApp(
          wiredTheme: WiredThemeData(
            borderColor: const Color(0xFF5C3D2E),
            textColor: const Color(0xFF2E2E2E),
            disabledTextColor: const Color(0xFFA89888),
            fillColor: const Color(0xFFF5ECD7),
            roughness: 1.2,
          ),
          initialRoute: '/',
          onGenerateRoute: (settings) {
            if (settings.name == '/') {
              return MaterialPageRoute(
                builder: (_) => Builder(
                  builder: (context) {
                    // Navigate immediately.
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      unawaited(Navigator.pushNamed(
                        context,
                        '/edit',
                        arguments: existingNote,
                      ));
                    });
                    return const SizedBox.shrink();
                  },
                ),
              );
            }
            if (settings.name == '/edit') {
              return MaterialPageRoute(
                settings: settings,
                builder: (_) => const EditPage(),
              );
            }
            return null;
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Note'), findsOneWidget);
      expect(find.text('Save Changes'), findsOneWidget);

      // Verify the text controllers are pre-filled.
      final titleField = tester.widgetList<EditableText>(
        find.byType(EditableText),
      );
      // The first EditableText should have the title, the second the content.
      final texts = titleField.map((e) => e.controller.text).toList();
      expect(texts, contains('My Existing Note'));
      expect(texts, contains('Existing content here.'));
    });

    testWidgets('back button exists with semantic label', (tester) async {
      await tester.pumpWidget(_wrapInApp(const EditPage()));
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('Go back'), findsOneWidget);
    });
  });

  group('Settings page', () {
    // Helper: navigate to settings page and return the NavigatorState so
    // the caller can pop back (required to dispose WiredSlider's timer).
    Future<NavigatorState> pumpSettings(WidgetTester tester) async {
      await tester.pumpWidget(const SketchNotesApp());
      await tester.pumpAndSettle();

      final navigator = tester.state<NavigatorState>(
        find.byType(Navigator),
      );
      unawaited(navigator.pushNamed('/settings'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
      return navigator;
    }

    /// Pop the settings page so WiredSlider's pending timer is disposed.
    Future<void> popSettings(
      WidgetTester tester,
      NavigatorState navigator,
    ) async {
      navigator.pop();
      await tester.pumpAndSettle();
    }

    testWidgets('dark mode switch is present', (tester) async {
      final nav = await pumpSettings(tester);

      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Toggle dark theme'), findsOneWidget);

      await popSettings(tester, nav);
    });

    testWidgets('roughness slider renders with initial value', (tester) async {
      final nav = await pumpSettings(tester);

      expect(find.text('Roughness: 1.2'), findsOneWidget);
      expect(
        find.text('Adjust the sketchiness of drawn elements'),
        findsOneWidget,
      );
      expect(find.byType(WiredSlider), findsOneWidget);

      await popSettings(tester, nav);
    });

    testWidgets('about list tile triggers about dialog', (tester) async {
      final nav = await pumpSettings(tester);

      expect(find.text('About'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);

      // Tap the About tile.
      await tester.tap(find.text('About'));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // The about dialog should be visible.
      expect(find.text('Sketch Notes'), findsWidgets);
      expect(
        find.textContaining('hand-drawn notes app'),
        findsOneWidget,
      );

      // Dismiss the dialog first, then pop settings.
      // The dialog has a close/back button or we can pop it.
      nav.pop(); // pop dialog
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      await popSettings(tester, nav);
    });

    testWidgets('renders section headers', (tester) async {
      final nav = await pumpSettings(tester);

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('General'), findsOneWidget);
      expect(find.text('Information'), findsOneWidget);

      await popSettings(tester, nav);
    });

    testWidgets('theme and font size tiles are rendered', (tester) async {
      final nav = await pumpSettings(tester);

      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Warm parchment'), findsOneWidget);
      expect(find.text('Font Size'), findsOneWidget);
      expect(find.text('Medium'), findsOneWidget);

      await popSettings(tester, nav);
    });
  });

  group('NoteCard widget', () {
    testWidgets('renders note title', (tester) async {
      final note = _sampleNote(title: 'My Note Title');
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      expect(find.text('My Note Title'), findsOneWidget);
    });

    testWidgets('shows content preview', (tester) async {
      final note = _sampleNote(
        content: 'Short content.',
      );
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      expect(find.text('Short content.'), findsOneWidget);
    });

    testWidgets('truncates long content with ellipsis indicator', (tester) async {
      final longContent = 'A' * 80; // Longer than 50 chars.
      final note = _sampleNote(content: longContent);
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      // The preview should be first 50 chars + '...'
      expect(find.text('${'A' * 50}...'), findsOneWidget);
    });

    testWidgets('shows color indicator circle', (tester) async {
      final note = _sampleNote(color: const Color(0xFFE8F5E9));
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      // Find the colored circle Container by its decoration.
      final container = tester.widgetList<Container>(
        find.byType(Container),
      ).where((c) {
        final decoration = c.decoration;
        if (decoration is BoxDecoration) {
          return decoration.color == const Color(0xFFE8F5E9) &&
              decoration.shape == BoxShape.circle;
        }
        return false;
      });
      expect(container, isNotEmpty);
    });

    testWidgets('shows "Untitled" when title is empty', (tester) async {
      final note = _sampleNote(title: '');
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      expect(find.text('Untitled'), findsOneWidget);
    });

    testWidgets('shows "new" badge when updated today', (tester) async {
      final note = _sampleNote(
        updatedAt: DateTime.now(), // Updated today.
      );
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      // The WiredBadge should show the 'new' label.
      expect(find.byType(WiredBadge), findsOneWidget);
    });

    testWidgets('does not show badge when updated in the past', (tester) async {
      final note = _sampleNote(
        updatedAt: DateTime(2020), // Far in the past.
      );
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      expect(find.byType(WiredBadge), findsNothing);
    });

    testWidgets('displays formatted date', (tester) async {
      final note = _sampleNote(
        updatedAt: DateTime(2025, 3, 15),
      );
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      expect(find.text('3/15/2025'), findsOneWidget);
    });

    testWidgets('onTap callback fires when tapped', (tester) async {
      var tapped = false;
      final note = _sampleNote();
      await tester.pumpWidget(
        _wrapInApp(NoteCard(note: note, onTap: () => tapped = true)),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Test Title'));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
    });
  });

  group('DrawerMenu widget', () {
    testWidgets('renders "All Notes" item', (tester) async {
      // DrawerMenu needs to be inside a Scaffold drawer slot.
      await tester.pumpWidget(
        _wrapInApp(
          WiredScaffold(
            drawer: const DrawerMenu(),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open the drawer.
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('All Notes'), findsOneWidget);
    });

    testWidgets('renders "Settings" item', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          WiredScaffold(
            drawer: const DrawerMenu(),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('renders "About" item', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          WiredScaffold(
            drawer: const DrawerMenu(),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('About'), findsOneWidget);
    });

    testWidgets('renders avatar with edit icon', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          WiredScaffold(
            drawer: const DrawerMenu(),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.byType(WiredAvatar), findsOneWidget);
    });

    testWidgets('drawer header shows "Sketch Notes" text', (tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          WiredScaffold(
            drawer: const DrawerMenu(),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // "Sketch Notes" appears in the drawer header.
      expect(find.text('Sketch Notes'), findsOneWidget);
    });
  });
}
