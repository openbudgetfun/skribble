import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:skribble_example/app.dart';
import 'package:skribble_example/models/note.dart';

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
  });
}
