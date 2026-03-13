import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:skribble/skribble.dart';

void main() {
  group('WiredCircularProgress', () {
    testWidgets('renders without error (indeterminate)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress())),
      );

      expect(find.byType(WiredCircularProgress), findsOneWidget);
    });

    testWidgets('renders without error (determinate)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress(value: 0.5))),
      );

      expect(find.byType(WiredCircularProgress), findsOneWidget);
    });

    testWidgets('default size is 48x48', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: WiredCircularProgress(value: 0.5)),
          ),
        ),
      );

      final size = tester.getSize(find.byType(WiredCircularProgress));
      expect(size.width, 48.0);
      expect(size.height, 48.0);
    });

    testWidgets('renders with custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(child: WiredCircularProgress(value: 0.5, size: 100.0)),
          ),
        ),
      );

      final size = tester.getSize(find.byType(WiredCircularProgress));
      expect(size.width, 100.0);
      expect(size.height, 100.0);
    });

    testWidgets('accepts value parameter', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress(value: 0.75))),
      );

      final progress = tester.widget<WiredCircularProgress>(
        find.byType(WiredCircularProgress),
      );
      expect(progress.value, 0.75);
    });

    testWidgets('value defaults to null (indeterminate)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress())),
      );

      final progress = tester.widget<WiredCircularProgress>(
        find.byType(WiredCircularProgress),
      );
      expect(progress.value, isNull);
    });

    testWidgets('strokeWidth defaults to 3', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress(value: 0.5))),
      );

      final progress = tester.widget<WiredCircularProgress>(
        find.byType(WiredCircularProgress),
      );
      expect(progress.strokeWidth, 3.0);
    });

    testWidgets('accepts custom strokeWidth', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: WiredCircularProgress(value: 0.5, strokeWidth: 5.0),
          ),
        ),
      );

      final progress = tester.widget<WiredCircularProgress>(
        find.byType(WiredCircularProgress),
      );
      expect(progress.strokeWidth, 5.0);
    });

    testWidgets('contains SizedBox wrapper', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress(value: 0.5))),
      );

      expect(
        find.descendant(
          of: find.byType(WiredCircularProgress),
          matching: find.byType(SizedBox),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains Stack for layering', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress(value: 0.5))),
      );

      expect(
        find.descendant(
          of: find.byType(WiredCircularProgress),
          matching: find.byType(Stack),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains WiredCanvas for background circle', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress(value: 0.5))),
      );

      expect(
        find.descendant(
          of: find.byType(WiredCircularProgress),
          matching: find.byType(WiredCanvas),
        ),
        findsOneWidget,
      );
    });

    testWidgets('contains CustomPaint for arc', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress(value: 0.5))),
      );

      expect(
        find.descendant(
          of: find.byType(WiredCircularProgress),
          matching: find.byType(CustomPaint),
        ),
        findsAtLeast(1),
      );
    });

    testWidgets('indeterminate mode animates', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress())),
      );

      // Pump a few frames to verify animation is running without errors.
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(WiredCircularProgress), findsOneWidget);
    });

    testWidgets('value at 0 renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress(value: 0.0))),
      );

      expect(find.byType(WiredCircularProgress), findsOneWidget);
    });

    testWidgets('value at 1 renders without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(home: Scaffold(body: WiredCircularProgress(value: 1.0))),
      );

      expect(find.byType(WiredCircularProgress), findsOneWidget);
    });
  });
}
