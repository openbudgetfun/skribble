import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

import 'package:skribble_example/app.dart';
import 'package:skribble_example/models/sketch_settings.dart';

/// Pumps Sketch Notes under [SkribbleApp], the Material-free shell, with
/// [WiredMaterialTheme] supplying the Material theme and localizations that
/// the app's remaining Material widgets look for.
Future<void> _pumpUnderSkribbleApp(
  WidgetTester tester, {
  String initialRoute = '/',
}) async {
  await tester.pumpWidget(
    SketchSettingsScope(
      notifier: ValueNotifier(const SketchSettings()),
      child: SkribbleApp(
        title: 'Sketch Notes',
        wiredTheme: dayParchment(roughness: 1.2),
        darkWiredTheme: nightParchment(roughness: 1.2),
        themeMode: SkribbleThemeMode.light,
        builder: (context, child) => WiredMaterialTheme(child: child!),
        initialRoute: initialRoute,
        routes: sketchNotesRoutes,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

/// Sketch Notes runs in [SkribbleApp], the shell AGENTS.md asks new
/// skribble apps to use, with a [WiredMaterialTheme] builder.
///
/// Without that builder every screen fails with "No MaterialLocalizations
/// found" or "No Material widget found": the text fields inside
/// [WiredInput], [WiredSearchBar], and [WiredTextArea] need them, the
/// drawer controller inside [WiredScaffold] needs them, and
/// `showWiredSnackBar` needs a `ScaffoldMessenger`. These tests keep every
/// screen working in that shell.
void main() {
  group('Sketch Notes under SkribbleApp', () {
    testWidgets('the settings page renders', (tester) async {
      await _pumpUnderSkribbleApp(tester, initialRoute: '/settings');

      expect(tester.takeException(), isNull);
      expect(find.text('Dark Mode'), findsOneWidget);
      expect(find.byType(WiredSlider), findsOneWidget);
    });

    testWidgets('the notes list renders', (tester) async {
      await _pumpUnderSkribbleApp(tester);

      expect(tester.takeException(), isNull);
      expect(find.text('Welcome to Sketch Notes'), findsOneWidget);
    });

    testWidgets('the search bar filters notes', (tester) async {
      await _pumpUnderSkribbleApp(tester);
      await tester.enterText(find.byType(EditableText).first, 'Shopping');
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Project Ideas'), findsNothing);
    });

    testWidgets('the drawer opens', (tester) async {
      await _pumpUnderSkribbleApp(tester);
      await tester.tap(find.bySemanticsLabel('Open menu'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('All Notes'), findsOneWidget);
    });

    testWidgets('the edit page renders', (tester) async {
      await _pumpUnderSkribbleApp(tester, initialRoute: '/edit');

      expect(tester.takeException(), isNull);
      expect(find.text('New Note'), findsOneWidget);
    });

    testWidgets('a new note can be written and saved', (tester) async {
      await _pumpUnderSkribbleApp(tester);
      await tester.tap(find.bySemanticsLabel('Create new note'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(EditableText).first, 'Buy ink');
      await tester.tap(find.text('Create Note'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Buy ink'), findsOneWidget);
    });

    testWidgets(
      'swiping a note away offers undo',
      (tester) async {
        await _pumpUnderSkribbleApp(tester);
        await tester.drag(find.text('Shopping List'), const Offset(-600, 0));
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Note deleted'), findsOneWidget);
      },
    );

    testWidgets('the about dialog opens', (tester) async {
      await _pumpUnderSkribbleApp(tester, initialRoute: '/settings');
      await tester.tap(find.text('About'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Version 1.0.0'), findsWidgets);
    });

    testWidgets('the back button returns to the list', (tester) async {
      await _pumpUnderSkribbleApp(tester);
      await tester.tap(find.bySemanticsLabel('Create new note'));
      await tester.pumpAndSettle();
      await tester.tap(find.bySemanticsLabel('Go back'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Welcome to Sketch Notes'), findsOneWidget);
    });
  });
}
