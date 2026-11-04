import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/app.dart';
import 'package:skribble_example/models/note.dart';
import 'package:skribble_example/models/sketch_settings.dart';
import 'package:skribble_example/pages/edit_page.dart';
import 'package:skribble_example/widgets/drawer_menu.dart';
import 'package:skribble_example/widgets/note_card.dart';

/// Wraps [child] in a [WiredMaterialApp] on day parchment.
Widget _wrapInApp(Widget child) {
  return WiredMaterialApp(
    wiredTheme: dayParchment(roughness: 1.2),
    home: child,
  );
}

/// Create a sample [Note] for testing purposes.
Note _sampleNote({
  String id = 'test-1',
  String title = 'Test Title',
  String content = 'Test content for the note.',
  Color color = const Color(0xFFF5ECD7),
  DateTime? updatedAt,
}) {
  final now = DateTime.now();
  return Note(
    id: id,
    title: title,
    content: content,
    color: color,
    createdAt: now,
    updatedAt: updatedAt ?? now,
  );
}

/// Pumps the whole app and pushes [route] over the notes list.
Future<NavigatorState> _pumpAppAt(WidgetTester tester, String route) async {
  await tester.pumpWidget(const SketchNotesApp());
  await tester.pumpAndSettle();
  final navigator = tester.state<NavigatorState>(find.byType(Navigator));
  if (route != '/') {
    navigator.pushNamed(route);
    await tester.pumpAndSettle();
  }
  return navigator;
}

/// Writes a note on the edit page and saves it.
Future<void> _writeNote(WidgetTester tester, String title) async {
  await tester.tap(find.bySemanticsLabel('Create new note'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField).first, title);
  await tester.tap(find.text('Create Note'));
  await tester.pumpAndSettle();
}

/// The settings the app is drawn with right now.
SketchSettings _settings(WidgetTester tester) =>
    SketchSettingsScope.of(tester.element(find.byType(Navigator))).value;

void main() {
  group('SketchNotesApp', () {
    testWidgets('home page shows the title and the sample notes', (
      tester,
    ) async {
      await _pumpAppAt(tester, '/');

      expect(find.text('Sketch Notes'), findsOneWidget);
      expect(find.text('Welcome to Sketch Notes'), findsOneWidget);
      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Project Ideas'), findsOneWidget);
      expect(find.bySemanticsLabel('Create new note'), findsOneWidget);
    });

    testWidgets('the FAB opens a blank edit page', (tester) async {
      await _pumpAppAt(tester, '/');

      await tester.tap(find.bySemanticsLabel('Create new note'));
      await tester.pumpAndSettle();

      expect(find.text('New Note'), findsOneWidget);
      expect(find.text('Create Note'), findsOneWidget);
    });

    testWidgets('a new note joins the list', (tester) async {
      await _pumpAppAt(tester, '/');

      await _writeNote(tester, 'Buy ink');

      expect(find.text('Buy ink'), findsOneWidget);
      expect(find.text('New Note'), findsNothing);
    });

    testWidgets('tapping a note edits it in place', (tester) async {
      await _pumpAppAt(tester, '/');

      await tester.tap(find.text('Shopping List'));
      await tester.pumpAndSettle();
      expect(find.text('Edit Note'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Groceries');
      await tester.tap(find.text('Save Changes'));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Shopping List'), findsNothing);
    });

    testWidgets('swiping a note away deletes it, and undo restores it', (
      tester,
    ) async {
      await _pumpAppAt(tester, '/');

      await tester.drag(find.text('Shopping List'), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(find.text('Shopping List'), findsNothing);
      expect(find.text('Note deleted'), findsOneWidget);

      await tester.tap(find.text('UNDO'));
      await tester.pumpAndSettle();

      expect(find.text('Shopping List'), findsOneWidget);
      // It returns to its old place, between the other two.
      final welcome = tester.getTopLeft(find.text('Welcome to Sketch Notes'));
      final shopping = tester.getTopLeft(find.text('Shopping List'));
      final ideas = tester.getTopLeft(find.text('Project Ideas'));
      expect(welcome.dy, lessThan(shopping.dy));
      expect(shopping.dy, lessThan(ideas.dy));
    });
  });

  group('Note model', () {
    test('Note.create generates unique IDs', () {
      final note1 = Note.create(title: 'A');
      final note2 = Note.create(title: 'B');
      expect(note1.id, isNot(equals(note2.id)));
    });

    test('Note.create defaults to parchment and stamps both times', () {
      final before = DateTime.now();
      final note = Note.create(title: 'Defaults');
      expect(note.color, const Color(0xFFF5ECD7));
      expect(note.content, isEmpty);
      expect(note.createdAt.isBefore(before), isFalse);
      expect(note.updatedAt, note.createdAt);
    });

    test('copyWith replaces only the given fields and keeps the identity', () {
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

    test('copyWith with color changes only the color', () {
      final note = Note.create(title: 'A', content: 'B');
      final updated = note.copyWith(color: const Color(0xFFE3F2FD));
      expect(updated.color, const Color(0xFFE3F2FD));
      expect(updated.title, 'A');
      expect(updated.content, 'B');
    });
  });

  group('SketchSettings', () {
    test('defaults to day parchment, gentle wobble, and medium text', () {
      const settings = SketchSettings();
      expect(settings.night, isFalse);
      expect(settings.roughness, 1.2);
      expect(settings.textSize, NoteTextSize.medium);
    });

    test('copyWith and equality cover every field', () {
      const settings = SketchSettings();
      final changed = settings.copyWith(textSize: NoteTextSize.large);
      expect(changed, isNot(settings));
      expect(changed.copyWith(textSize: NoteTextSize.medium), settings);
      expect(
        settings.copyWith(night: true).hashCode,
        isNot(settings.hashCode),
      );
    });
  });

  group('Home page', () {
    testWidgets('search bar is present with hint text', (tester) async {
      await _pumpAppAt(tester, '/');
      expect(find.text('Search notes...'), findsOneWidget);
    });

    testWidgets('search filters notes by title', (tester) async {
      await _pumpAppAt(tester, '/');

      await tester.enterText(find.byType(TextField).first, 'Shopping');
      await tester.pumpAndSettle();

      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Welcome to Sketch Notes'), findsNothing);
      expect(find.text('Project Ideas'), findsNothing);
    });

    testWidgets('search filters notes by content', (tester) async {
      await _pumpAppAt(tester, '/');

      await tester.enterText(find.byType(TextField).first, 'coffee beans');
      await tester.pumpAndSettle();

      expect(find.text('Shopping List'), findsOneWidget);
      expect(find.text('Welcome to Sketch Notes'), findsNothing);
      expect(find.text('Project Ideas'), findsNothing);
    });

    testWidgets('a search that matches nothing says so', (tester) async {
      await _pumpAppAt(tester, '/');

      await tester.enterText(find.byType(TextField).first, 'xyznonexistent');
      await tester.pumpAndSettle();

      expect(find.text('No notes match your search.'), findsOneWidget);
    });

    testWidgets('the menu button opens the drawer', (tester) async {
      await _pumpAppAt(tester, '/');

      await tester.tap(find.bySemanticsLabel('Open menu'));
      await tester.pumpAndSettle();

      expect(find.text('All Notes'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('"All Notes" closes the drawer and keeps new notes', (
      tester,
    ) async {
      await _pumpAppAt(tester, '/');
      await _writeNote(tester, 'Keep me');

      await tester.tap(find.bySemanticsLabel('Open menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All Notes'));
      await tester.pumpAndSettle();

      expect(find.text('All Notes'), findsNothing);
      expect(find.text('Keep me'), findsOneWidget);
    });

    testWidgets('the drawer opens settings and the about dialog', (
      tester,
    ) async {
      final navigator = await _pumpAppAt(tester, '/');

      await tester.tap(find.bySemanticsLabel('Open menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();
      expect(find.text('Dark Mode'), findsOneWidget);

      navigator.pop();
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Open menu'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();
      expect(
        find.text(
          'A hand-drawn notes app built with the skribble design system.',
        ),
        findsOneWidget,
      );
    });
  });

  group('Edit page', () {
    testWidgets('renders title and content input fields for new note', (
      tester,
    ) async {
      await tester.pumpWidget(_wrapInApp(const EditPage()));
      await tester.pumpAndSettle();

      expect(find.text('New Note'), findsOneWidget);
      expect(find.text('Note title...'), findsOneWidget);
      expect(find.text('Write your thoughts...'), findsOneWidget);
      expect(find.text('Create Note'), findsOneWidget);
      expect(find.bySemanticsLabel('Go back'), findsOneWidget);
    });

    testWidgets('color chips are displayed with all labels', (tester) async {
      await tester.pumpWidget(_wrapInApp(const EditPage()));
      await tester.pumpAndSettle();

      expect(find.text('Label color'), findsOneWidget);
      for (final name in ['Parchment', 'Green', 'Blue', 'Orange', 'Purple']) {
        expect(find.text(name), findsOneWidget);
      }
    });

    testWidgets('choosing a colour selects its chip and saves it', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpAppAt(tester, '/');
      await tester.tap(find.bySemanticsLabel('Create new note'));
      await tester.pumpAndSettle();

      SemanticsNode chip(String name) => tester.getSemantics(
        find.ancestor(
          of: find.text(name),
          matching: find.byType(WiredChoiceChip),
        ),
      );
      expect(chip('Parchment'), isSemantics(isSelected: true));

      await tester.tap(find.text('Blue'));
      await tester.pump();
      expect(chip('Blue'), isSemantics(isSelected: true));
      expect(chip('Parchment'), isSemantics(isSelected: false));

      await tester.enterText(find.byType(TextField).first, 'Sky');
      await tester.tap(find.text('Create Note'));
      await tester.pumpAndSettle();

      final card = tester.widget<NoteCard>(
        find.ancestor(of: find.text('Sky'), matching: find.byType(NoteCard)),
      );
      expect(card.note.color, const Color(0xFFD9E7F5));
      semantics.dispose();
    });

    testWidgets(
      'editing an existing note pre-fills fields and shows Edit title',
      (tester) async {
        final existingNote = _sampleNote(
          title: 'My Existing Note',
          content: 'Existing content here.',
        );

        await tester.pumpWidget(
          WiredMaterialApp(
            wiredTheme: dayParchment(roughness: 1.2),
            onGenerateRoute: (settings) => MaterialPageRoute(
              settings: RouteSettings(arguments: existingNote),
              builder: (_) => const EditPage(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Edit Note'), findsOneWidget);
        expect(find.text('Save Changes'), findsOneWidget);
        final texts = tester
            .widgetList<EditableText>(find.byType(EditableText))
            .map((e) => e.controller.text);
        expect(texts, contains('My Existing Note'));
        expect(texts, contains('Existing content here.'));
      },
    );
  });

  group('Settings page', () {
    testWidgets('renders its sections and controls', (tester) async {
      await _pumpAppAt(tester, '/settings');

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Information'), findsOneWidget);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.text('Warm parchment'), findsOneWidget);
      expect(find.text('Roughness: 1.2'), findsOneWidget);
      expect(
        find.text('Adjust the sketchiness of drawn elements'),
        findsOneWidget,
      );
      expect(find.byType(WiredSlider), findsOneWidget);
      expect(find.text('Text Size'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);
    });

    testWidgets('section titles are headings for screen readers', (
      tester,
    ) async {
      final semantics = tester.ensureSemantics();
      await _pumpAppAt(tester, '/settings');

      expect(
        tester.getSemantics(find.text('Appearance')),
        isSemantics(label: 'Appearance', isHeader: true),
      );
      semantics.dispose();
    });

    testWidgets('dark mode redraws the whole app on night parchment', (
      tester,
    ) async {
      final navigator = await _pumpAppAt(tester, '/settings');
      final day = WiredTheme.of(tester.element(find.text('Dark Mode')));

      await tester.tap(find.byType(WiredSwitch));
      await tester.pumpAndSettle();

      final night = WiredTheme.of(tester.element(find.text('Dark Mode')));
      expect(night.fillColor, isNot(day.fillColor));
      expect(night.textColor, const Color(0xFFF5ECD7));
      expect(find.text('Night parchment'), findsOneWidget);

      // The home page underneath is on night parchment too.
      navigator.pop();
      await tester.pumpAndSettle();
      expect(
        WiredTheme.of(tester.element(find.byType(Scaffold).first)).fillColor,
        night.fillColor,
      );
    });

    testWidgets('the roughness slider changes the app theme', (tester) async {
      await _pumpAppAt(tester, '/settings');
      final slider = tester.getRect(find.byType(WiredSlider));
      await tester.tapAt(Offset(slider.right - 14, slider.center.dy));
      await tester.pumpAndSettle();

      final theme = WiredTheme.of(tester.element(find.text('Dark Mode')));
      expect(theme.roughness, greaterThan(2));
      expect(find.text('Roughness: 1.2'), findsNothing);
    });

    testWidgets('text size scales the text across the app', (tester) async {
      await _pumpAppAt(tester, '/settings');
      double scale() => MediaQuery.textScalerOf(
        tester.element(find.text('Dark Mode')),
      ).scale(14);
      expect(scale(), 14);

      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();
      expect(_settings(tester).textSize, NoteTextSize.large);
      expect(scale(), closeTo(14 * 1.3, 0.01));

      await tester.tap(find.text('Small'));
      await tester.pumpAndSettle();
      expect(scale(), closeTo(14 * 0.9, 0.01));
    });

    testWidgets('text size multiplies the system text size', (tester) async {
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
      await _pumpAppAt(tester, '/settings');

      await tester.tap(find.text('Large'));
      await tester.pumpAndSettle();

      final scaler = MediaQuery.textScalerOf(
        tester.element(find.text('Dark Mode')),
      );
      expect(scaler.scale(14), closeTo(14 * 2 * 1.3, 0.01));
    });

    testWidgets('the about tile opens the about dialog', (tester) async {
      await _pumpAppAt(tester, '/settings');

      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(find.text('Sketch Notes'), findsWidgets);
      expect(
        find.text(
          'A hand-drawn notes app built with the skribble design system.',
        ),
        findsOneWidget,
      );
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
      final note = _sampleNote(content: 'Short content.');
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      expect(find.text('Short content.'), findsOneWidget);
    });

    testWidgets('truncates long content with ellipsis indicator', (
      tester,
    ) async {
      final note = _sampleNote(content: 'A' * 80);
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      expect(find.text('${'A' * 50}...'), findsOneWidget);
    });

    testWidgets('shows color indicator circle', (tester) async {
      final note = _sampleNote(color: const Color(0xFFE8F5E9));
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      final dots = tester.widgetList<Container>(find.byType(Container)).where((
        c,
      ) {
        final decoration = c.decoration;
        return decoration is BoxDecoration &&
            decoration.color == const Color(0xFFE8F5E9) &&
            decoration.shape == BoxShape.circle;
      });
      expect(dots, isNotEmpty);
    });

    testWidgets('shows "Untitled" when title is empty', (tester) async {
      final note = _sampleNote(title: '');
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      expect(find.text('Untitled'), findsOneWidget);
    });

    testWidgets('shows "new" badge when updated today', (tester) async {
      final note = _sampleNote(updatedAt: DateTime.now());
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      expect(find.byType(WiredBadge), findsOneWidget);
    });

    testWidgets('does not show badge when updated in the past', (tester) async {
      final note = _sampleNote(updatedAt: DateTime(2020));
      await tester.pumpWidget(_wrapInApp(NoteCard(note: note)));
      await tester.pumpAndSettle();

      expect(find.byType(WiredBadge), findsNothing);
    });

    testWidgets('displays formatted date', (tester) async {
      final note = _sampleNote(updatedAt: DateTime(2025, 3, 15));
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
    /// Pumps a scaffold with the drawer and opens it.
    Future<void> pumpOpenDrawer(WidgetTester tester) async {
      await tester.pumpWidget(
        _wrapInApp(
          WiredScaffold(
            drawer: const DrawerMenu(),
            body: Builder(
              builder: (context) => WiredButton(
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
    }

    testWidgets('renders the header and every item', (tester) async {
      await pumpOpenDrawer(tester);

      expect(find.text('Sketch Notes'), findsOneWidget);
      expect(find.byType(WiredAvatar), findsOneWidget);
      expect(find.text('All Notes'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
    });
  });
}
